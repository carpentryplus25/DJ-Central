//
//  MainViewController.swift
//  DJ Central
//
//  Created by William Thompson on 6/8/17.
//  Copyright © 2017 J.W Enterprises, LLC. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController, SlideRevealViewDelegate, MPMediaPickerControllerDelegate {

    static let didUpdateState = NSNotification.Name("didUpdateState")
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    @IBOutlet weak var hostButton: UIBarButtonItem!
    @IBOutlet weak var artWorkImage: UIImageView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var libraryView: UIView!
    @IBOutlet weak var hostView: UIView!
    @IBOutlet weak var nowPlayingView: UIView!
    @IBOutlet weak var browseHostLibrary: UIView!
    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    @IBOutlet weak var browseButton: UIBarButtonItem!
    @IBOutlet weak var libraryButton: UIBarButtonItem!
    @IBOutlet weak var searchView: UIView!
    
    
    //var mediaPlayer = MPMusicPlayerController()
    //let serviceManger = ServiceManager()
    var hostViewController: HostViewController?
    var interactor = SlideRevealViewInteractor()
    var delegate: SlideRevealViewDelegate? = nil
    var appleMusicManager = AppleMusicManager()
    var musicPlayerManager = MusicPlayerManager()
    var menuViewController = MenuViewController()
    var mediaItem = [[MediaItem]]()
    let imageManager = ImageManager()
    var isSearchPresented: Bool = false
    var searchAppleMusicTableViewController: SearchAppleMusicTableViewController!
    var session: DJCentralSession?
    var song: MPMediaItem?
    var isMenuPresented = false
    
    lazy var authorizationManager: AuthorizationManager = {
        return AuthorizationManager(appleMusicManager: self.appleMusicManager)
    }()
    lazy var mediaLibraryManager: MediaLibraryManager = {
        return MediaLibraryManager(authorizationManager: self.authorizationManager)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationManager.requestMediaLibrayAuthorization()
        authorizationManager.requestCloudServiceAuthorization()
        view.bringSubview(toFront: hostView)
        //view.bringSubview(toFront: artWorkImage)
        //updateInterface()
        NotificationCenter.default.addObserver(self,selector: #selector(handleMusicPlayerManagerDidUpdateState),name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMusicPlayerManagerDidUpdateState), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        session = DJCentralSession(peerDisplayName: UIDevice.current.name)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        authorizationManager.requestCloudServiceCapabilities()
        isMenuPresented = false
        
    }
    
    func updateInterface() {
        if musicPlayerManager.musicPlayerController.playbackState == .playing || musicPlayerManager.musicPlayerController.playbackState == .paused {
            if let currentItem = musicPlayerManager.musicPlayerController.nowPlayingItem {
                let albumTitle = currentItem.albumTitle
                let artist = currentItem.artist
                let songTitle = currentItem.title
                let playbackTime = musicPlayerManager.musicPlayerController.currentPlaybackTime
                let durationTime = currentItem.playbackDuration
                //song = currentItem
                //sendUserInterfaceData(from: currentItem)
                
                if let artwork = musicPlayerManager.musicPlayerController.nowPlayingItem?.artwork, let image = artwork.image(at: artWorkImage.frame.size) {
                    print("using local image")
                    artWorkImage.image = image
                    setArtworkImages(image, title: songTitle!, playbackTime: playbackTime, durationTime: durationTime)
                    changeColors()
                } else {
                    guard let developerToken = appleMusicManager.fetchDeveloperToken() else {
                        print("oops")
                        return }
                    let searchTypes = "songs"
                    var searchURLComponents = URLComponents()
                    searchURLComponents.scheme = "https"
                    searchURLComponents.host = "api.music.apple.com"
                    searchURLComponents.path = "/v1/catalog/"
                    searchURLComponents.path += "\(authorizationManager.cloudServiceStoreFrontCountryCode)"
                    searchURLComponents.path += "/search"
                    let expectedArtist = artist?.replacingOccurrences(of: " ", with: "+")
                    let expectedAlbum = albumTitle?.replacingOccurrences(of: " ", with: "+")
                    let artistExpected = expectedArtist?.replacingOccurrences(of: "&", with: "")
                    let expectingArtist = artistExpected?.replacingOccurrences(of: "++", with: "+")
                    searchURLComponents.queryItems = [
                        URLQueryItem(name: "term", value: (expectingArtist! + "-" + expectedAlbum!)),
                        URLQueryItem(name: "types", value: searchTypes)
                    ]
                    print(albumTitle!)
                    var request = URLRequest(url: searchURLComponents.url!)
                    request.httpMethod = "GET"
                    request.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
                    let dataTask = URLSession.shared.dataTask(with: request) {
                        (data, response, error) in
                        print(response!)
                        if let searchData = data {
                            guard let results = try? self.appleMusicManager.processMediaItemSections(searchData)    else {return}
                            self.mediaItem = results
                            let album = self.mediaItem[0][0]
                            DispatchQueue.main.async {
                                let albumArtworkURL = album.artwork.imageUrl(self.artWorkImage.frame.size)
                                self.imageManager.fetchImage(url: albumArtworkURL) {(image) in
                                    self.artWorkImage.image = image
                                    self.setArtworkImages(image!, title: songTitle!, playbackTime: playbackTime, durationTime: durationTime)
                                    self.changeColors()
                                }
                            }
                        }
                    }
                    dataTask.resume()
                }
            }
        }
        else if musicPlayerManager.musicPlayerController.playbackState == .stopped{
            let image: UIImage = UIImage(named: "Album_Art")!
            setArtworkImages(image, title: " ", playbackTime: 0, durationTime: 0)
            changeColors()
            //stopTimer()
        }
    }
    func setArtworkImages(_ image: UIImage, title: String, playbackTime: TimeInterval, durationTime: TimeInterval) {
        artWorkImage.image = image
        //let blurImage = CIImage(image: image)
        //let blurFilter = CIFilter(name: "CIGaussianBlur")
        //blurFilter?.setValue(blurImage, forKey: kCIInputImageKey)
        //blurFilter?.setValue(25, forKey: kCIInputRadiusKey)
        //let context = CIContext()
        //let cgImage = context.createCGImage((blurFilter?.outputImage)!, from: blurImage!.extent)
        //let blurredImage = UIImage(cgImage: cgImage!)
            //blurArtworkImage.image = blurredImage
        let centerPoint = CGPoint(x: artWorkImage.center.x, y: artWorkImage.center.y)
        let color: UIColor = (artWorkImage.image?.getPixelColor(centerPoint))!
        
        let inversedColor = artWorkImage.image?.inversedColor(centerPoint)
        var info = [AnyHashable:Any]()
        info["artwork"] = image
        info["title"] = title
        info["playbackTime"] = playbackTime
        info["durationTime"] = durationTime
        info["color"] = color
        info["inversedColor"] = inversedColor
        session?.send(NSKeyedArchiver.archivedData(withRootObject: info))
        let data = NSKeyedArchiver.archivedData(withRootObject: info)
        session?.delegate?.session(session!, holdData: data)
        //changeColors()
    }
        
    func sendUserInterfaceData(from currentItem: MPMediaItem) {
        var info = [AnyHashable: Any]()
        info["title"] = currentItem.value(forProperty: MPMediaItemPropertyTitle)
        info["artist"] = currentItem.value(forProperty: MPMediaItemPropertyArtist)
        let artwork: MPMediaItemArtwork = currentItem.value(forProperty: MPMediaItemPropertyArtwork) as! MPMediaItemArtwork
        let image: UIImage? = artwork.image(at: artWorkImage.frame.size)
        if image != nil {
            info["artwork"] = image
        }
        
        session?.send(NSKeyedArchiver.archivedData(withRootObject: info))
        let data = NSKeyedArchiver.archivedData(withRootObject: info)
        session?.delegate?.session(session!, holdData: data)
        print(info)
        //let peers = session?.connectedPeers()
        /*
         if peers!.count > 0 {
         outputStreamer = DJCentralOutputStream(outputStream: (session?.outputStream(forPeer: peers![0]))!)
         outputStreamer?.streamAudio(from: song?.value(forProperty: MPMediaItemPropertyAssetURL) as! URL)
         outputStreamer?.start()
         }
         */
    }
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeColors() {
        let centerPoint = CGPoint(x: artWorkImage.center.x, y: artWorkImage.center.y)
        let inversedColor = artWorkImage.image?.inversedColor(centerPoint)
        //let color = artWorkImage.image?.getPixelColor(centerPoint)
        //print(color)
        //print("inversed Color\(inversedColor)")
        UIBarButtonItem.appearance().tintColor = inversedColor
        menuButton.tintColor = inversedColor
        searchButton.tintColor = inversedColor
        favoritesButton.tintColor = inversedColor
        hostButton.tintColor = inversedColor
        browseButton.tintColor = inversedColor
        nowPlayingButton.tintColor = inversedColor
        libraryButton.tintColor = inversedColor
        changeStatusBarStyle()
        //send(color: color!, inversedColor: inversedColor!)
    }
    
    func send(color: UIColor, inversedColor: UIColor) {
        var info = [AnyHashable: Any]()
        info["color"] = color
        info["inversedColor"] = inversedColor
        session?.send(NSKeyedArchiver.archivedData(withRootObject: info))
    }
    
    func skipToNextItem() {
        musicPlayerManager.musicPlayerController.skipToNextItem()
    }
    
    func skipBackToBeginningOrPreviousItem() {
        if musicPlayerManager.musicPlayerController.currentPlaybackTime < 5 {
            musicPlayerManager.musicPlayerController.skipToPreviousItem()
        }
        else {
            musicPlayerManager.musicPlayerController.skipToBeginning()
        }
    }
    
    func togglePlayPause() {
        if musicPlayerManager.musicPlayerController.playbackState == .playing {
            musicPlayerManager.musicPlayerController.pause()
        }
        else {
            musicPlayerManager.musicPlayerController.play()
        }
    }
    
    func changeStatusBarStyle(){
        let centerPoint = CGPoint(x: artWorkImage.center.x, y: artWorkImage.center.y)
        guard (artWorkImage.image != nil) else { return}
        if menuButton.tintColor! >= (artWorkImage.image?.getPixelColor(centerPoint))! {
            self.navigationController?.navigationBar.barStyle = .black
        }
        else {
            self.navigationController?.navigationBar.barStyle = .default
        }
    }
    
    func reopenMenu() {
        isMenuPresented = true
        performSegue(withIdentifier: "slideMenu", sender: nil)
    }
    
    func slideMenu(_ segueName: String, sender: AnyObject?) {
        dismiss(animated: true) {
            self.isMenuPresented = true
            self.performSegue(withIdentifier: segueName, sender: sender)
        }
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        if isSearchPresented == true {
            searchAppleMusicTableViewController = SearchAppleMusicTableViewController()
            searchAppleMusicTableViewController.searchController.isActive = false
            isMenuPresented = true
            self.performSegue(withIdentifier: "slideMenu", sender: nil)
        }
        else {
            isMenuPresented = true
            self.performSegue(withIdentifier: "slideMenu", sender: nil)
        }
    }
    
    @IBAction func hostAction(_ sender: Any) {
        
        view.bringSubview(toFront: hostView)
        //view.bringSubview(toFront: artWorkImage)
        view.sendSubview(toBack: searchView)
        view.sendSubview(toBack: favoritesView)
        view.sendSubview(toBack: libraryView)
        view.sendSubview(toBack: nowPlayingView)
        view.sendSubview(toBack: browseHostLibrary)
        
    }

    @IBAction func nowPlayingAction(_ sender: Any) {
        view.bringSubview(toFront: nowPlayingView)
        view.sendSubview(toBack: favoritesView)
        view.sendSubview(toBack: libraryView)
        view.sendSubview(toBack: hostView)
        view.sendSubview(toBack: browseHostLibrary)
        view.sendSubview(toBack: searchView)
    
    
    
    }
    @IBAction func browseHostAction(_ sender: Any) {
        view.bringSubview(toFront: browseHostLibrary)
        view.sendSubview(toBack: favoritesView)
        view.sendSubview(toBack: libraryView)
        view.sendSubview(toBack: hostView)
        view.sendSubview(toBack: nowPlayingView)
        view.sendSubview(toBack: searchView)
    
    
    }
    
    @IBAction func libraryAction(_ sender: Any) {
        view.bringSubview(toFront: libraryView)
        view.sendSubview(toBack: favoritesView)
        view.sendSubview(toBack: browseHostLibrary)
        view.sendSubview(toBack: hostView)
        view.sendSubview(toBack: nowPlayingView)
        view.sendSubview(toBack: searchView)
    
    
    
    }
    
    @IBAction func favoriteAction(_ sender: Any) {
        view.bringSubview(toFront: favoritesView)
        view.sendSubview(toBack: libraryView)
        view.sendSubview(toBack: browseHostLibrary)
        view.sendSubview(toBack: hostView)
        view.sendSubview(toBack: nowPlayingView)
        view.sendSubview(toBack: searchView)
    
    
    }
    
    @IBAction func searchAction(_ sender: Any) {
        isSearchPresented = true
        view.bringSubview(toFront: searchView)
        view.sendSubview(toBack: favoritesView)
        view.sendSubview(toBack: libraryView)
        view.sendSubview(toBack: browseHostLibrary)
        view.sendSubview(toBack: nowPlayingView)
        view.sendSubview(toBack: hostView)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MenuViewController {
            destination.transitioningDelegate = self
            destination.interactor = interactor
            destination.delegate = self
        }
    }
   
    @IBAction func edgePanGesture(_ sender: UIPanGestureRecognizer) {
        sender.requiresExclusiveTouchType = false
        let translation = sender.translation(in: view)
        let progress = SlideRevealViewHelper.calculateProgress(translation, viewBounds: view.frame, direction: .Down)
        SlideRevealViewHelper.mapGestureStateToInteractor(sender.state, progress: progress, interactor: interactor){
            isMenuPresented = true
            self.performSegue(withIdentifier: "slideMenu", sender: nil)
        }
        
        
    }
    
    func delay(seconds: Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if isMenuPresented {
            dismiss(animated: true) {
                self.delay(seconds: 0.5) {
                    self.reopenMenu()
                }
            }
        }
    }
    
    @objc func handleMusicPlayerManagerDidUpdateState() {
        DispatchQueue.main.async {
            if self.musicPlayerManager.musicPlayerController.playbackState == .playing || self.musicPlayerManager.musicPlayerController.playbackState == .paused {
            self.updateInterface()
            self.changeStatusBarStyle()
            }
        }
    }
    
    @IBAction func invite(_ sender: Any) {
        self.present((session?.browserViewController(forSeriviceType: "DJ-Central"))!, animated: true, completion: nil)
    
    
    
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true, completion: nil)
        song = mediaItemCollection.items[0]
        var info = [AnyHashable : Any]()
        info["title"] = song?.value(forProperty: MPMediaItemPropertyTitle)
        info["artist"] = song?.value(forProperty: MPMediaItemPropertyArtist)
        let artwork: MPMediaItemArtwork = song?.value(forProperty: MPMediaItemPropertyArtwork) as! MPMediaItemArtwork
        let image: UIImage? = artwork.image(at: artWorkImage.frame.size)!
        if image != nil {
            info["artwork"] = image
        }
        if info["artwork"] != nil {
            //setArtworkImages(image!)
        }
        session?.send(NSKeyedArchiver.archivedData(withRootObject: info))
    }
    
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addSong(_ sender: Any) {
        let picker: MPMediaPickerController = MPMediaPickerController(mediaTypes: MPMediaType.music)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideRevealViewAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideRevealDismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    
    
}
















