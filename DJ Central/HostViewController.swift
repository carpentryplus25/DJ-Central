//
//  HostViewController.swift
//  DJ Central
//
//  Created by William Thompson on 6/8/17.
//  Copyright © 2017 J.W. Enterprises, LLC. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreImage
import StoreKit

class HostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SongsTableViewCellDelegate {
    
    

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var percentageCompletedLabel: UILabel!
    @IBOutlet weak var percentageRemainingLabel: UILabel!
    @IBOutlet weak var progressIndicator: UISlider!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artWorkImage: UIImageView!
    @IBOutlet weak var blurArtworkImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reverseSkip: UIButton!
    
    //var mediaPlayer = MPMusicPlayerApplicationController()
    var mainViewController = MainViewController()
    var artWorkImages: [UIImage]!
    var albumTitle: [String]!
    var artistTitle: [String]!
    var songTitle: [String]!
    var timer: Timer?
    var albums: [AlbumInfo] = []
    var musicQuery: MusicQuery = MusicQuery()
    var appleMusicManager = AppleMusicManager()
    var musicPlayerManager = MusicPlayerManager()
    lazy var authorizationManager: AuthorizationManager = {
        return AuthorizationManager(appleMusicManager: self.appleMusicManager)
    }()
    lazy var mediaLibraryManager: MediaLibraryManager = {
        return MediaLibraryManager(authorizationManager: self.authorizationManager)
    }()
    var mediaItem = [[MediaItem]]()
    let imageManager = ImageManager()
    var endDate: NSDate!
    var coundDownTimer: Timer?
    var remainingTime: TimeInterval = 0
    var startDate: NSDate!
    var countUpTimer = Timer()
    var startTime: TimeInterval = 0
    var images: UIImage?
    var isUsingLocalImage: Bool = false
    var isUsingCachedImage: Bool = false
    var isFetchingImage: Bool = false
    var voteCount = 0
    var session: DJCentralSession?
    var outputStreamer: DJCentralOutputStream?
    var song: MPMediaItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = DJCentralSession(peerDisplayName: UIDevice.current.name)
        
        let notificationCenter: NotificationCenter = NotificationCenter.default
        guard MPMediaLibrary.authorizationStatus() == .authorized else {return}
        MPMediaLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                self.albums = self.musicQuery.get(songCategory: "Artist")
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            default:
                break
            }
            notificationCenter.post(name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
        }
        notificationCenter.addObserver(self, selector: #selector(handleMusicPlayerNowPlayingItemDidChange), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleMusicPlayerDidChangeState), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        
       
        
        startTimer()
        //changeColors()
        updatePlayBackControls()
        updateUserInterface()
        
        guard SKCloudServiceController.authorizationStatus() == .notDetermined else {
            return
        }
        let appleMusicManager = AppleMusicManager()
        let authorizationManager = AuthorizationManager(appleMusicManager: appleMusicManager)
        SKCloudServiceController.requestAuthorization {(authorizationStatus) in
            switch authorizationStatus {
            case .authorized:
                authorizationManager.requestCloudServiceCapabilities()
                authorizationManager.requestStoreFrontCountryCode()
            default:
                break
            }
            notificationCenter.post(name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        changeColors()
        //updateUserInterface()
        //updatePlayBackControls()
        //startTimer()
        //stopPlayback()
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func stopPlayback() {
        musicPlayerManager.musicPlayerController.stop()
    }
    
    func displayMediaLibraryError() {
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted by coporate or parental settings."
        case .denied:
            error = "Media library access denied by user."
        default:
            error = "Unknown error"
        }
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }))
        present(controller, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUserInterface() {
        if musicPlayerManager.musicPlayerController.playbackState == .playing || musicPlayerManager.musicPlayerController.playbackState == .paused {
            if let currentItem = musicPlayerManager.musicPlayerController.nowPlayingItem {
                songTitleLabel.text = currentItem.title
                let albumTitle = currentItem.albumTitle
                let artist = currentItem.artist
                if let artwork = musicPlayerManager.musicPlayerController.nowPlayingItem?.artwork, let image = artwork.image(at: artWorkImage.frame.size) {
                    //print("using local image")
                    isUsingLocalImage = true
                    setArtworkImages(image)
                    //changeColors()
                } else {
                    isUsingLocalImage = false
                    guard let developerToken = appleMusicManager.fetchDeveloperToken() else {print("oops");return}
                    let searchTypes = "songs"
                    var searchURLComponents = URLComponents()
                    searchURLComponents.scheme = "https"
                    searchURLComponents.host = "api.music.apple.com"
                    searchURLComponents.path = "/v1/catalog/"
                    searchURLComponents.path += "\(authorizationManager.cloudServiceStoreFrontCountryCode)"
                    searchURLComponents.path += "/search"
                    let expectedArtist = artist?.replacingOccurrences(of: " ", with: "+")
                    let artistExpected = expectedArtist?.replacingOccurrences(of: "&", with: "")
                    let expectingArtist = artistExpected?.replacingOccurrences(of: "++", with: "+")
                    let expectedAlbum = albumTitle?.replacingOccurrences(of: " ", with: "+")
                    searchURLComponents.queryItems = [
                        URLQueryItem(name: "term", value: (expectingArtist! + "-" + expectedAlbum!)),
                        URLQueryItem(name: "types", value: searchTypes)
                    ]
                    var request = URLRequest(url: searchURLComponents.url!)
                    request.httpMethod = "GET"
                    request.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
                    let dataTask = URLSession.shared.dataTask(with: request) {
                        (data, response, error) in
                        print(response!)
                        print("data\(data!)")
                        if let searchData = data {
                            guard let results = try? self.appleMusicManager.processMediaItemSections(searchData) else {
                                print("returned out of guard")
                                return}
                            self.mediaItem = results
                            let album = self.mediaItem[0][0]
                            DispatchQueue.main.async {
                                let albumArtworkURL = album.artwork.imageUrl(self.artWorkImage.frame.size)
                                self.imageManager.fetchImage(url: albumArtworkURL) {(image) in
                                    //print("fetching image")
                                    self.setArtworkImages(image!)
                                    //self.changeColors()
                                }
                            }
                        }
                    }
                    dataTask.resume()
                }
            } else {
                songTitleLabel.text = " "
                let image: UIImage = UIImage(named: "Album_Art")!
                setArtworkImages(image)
                //changeColors()
            }
        } else if musicPlayerManager.musicPlayerController.playbackState == .stopped{
            let image: UIImage = UIImage(named: "Album_Art")!
            setArtworkImages(image)
            //changeColors()
            stopTimer()
        }
    }
    
    func setArtworkImages(_ image: UIImage) {
        artWorkImage.image = image
        let blurImage = CIImage(image: image)
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(blurImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(25, forKey: kCIInputRadiusKey)
        let context = CIContext()
        let cgImage = context.createCGImage((blurFilter?.outputImage)!, from: blurImage!.extent)
        let blurredImage = UIImage(cgImage: cgImage!)
        blurArtworkImage.image = blurredImage
        changeColors()
    }
    
    func changeColors() {
        let centerPoint = CGPoint(x: artWorkImage.center.x, y: artWorkImage.center.x)
        //let color = artWorkImage.image?.getPixelColor(centerPoint)
        //let inversedColor = artWorkImage.image?.inversedColor(centerPoint)
        navigationController?.navigationBar.barTintColor = artWorkImage.image?.getPixelColor(centerPoint)
        navigationController?.toolbar.barTintColor = artWorkImage.image?.getPixelColor(centerPoint)
        songTitleLabel.textColor = artWorkImage.image?.inversedColor(centerPoint)
        progressIndicator.minimumTrackTintColor = artWorkImage.image?.getPixelColor(centerPoint)
        progressIndicator.maximumTrackTintColor = songTitleLabel.textColor
        progressIndicator.thumbTintColor = songTitleLabel.textColor
        favoriteButton.tintColor = songTitleLabel.textColor
        playButton.tintColor = songTitleLabel.textColor
        skipButton.tintColor = songTitleLabel.textColor
        songTitleLabel.tintColor = songTitleLabel.textColor
        percentageCompletedLabel.textColor = songTitleLabel.textColor
        percentageRemainingLabel.textColor = songTitleLabel.textColor
        playButton.tintColor = songTitleLabel.textColor
        reverseSkip.tintColor = songTitleLabel.textColor
        
    }
    
    
    @objc func updateSlider() {
        if musicPlayerManager.musicPlayerController.playbackState == .playing {
            let currentPlaybackTime = musicPlayerManager.musicPlayerController.currentPlaybackTime
            if !currentPlaybackTime.isNaN && !currentPlaybackTime.isInfinite {
                let minute_ = Int(currentPlaybackTime) / 60
                let second_ = Int(musicPlayerManager.musicPlayerController.currentPlaybackTime.truncatingRemainder(dividingBy: 60))
                let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
                let second = second_ > 9 ? "\(second_)" : "0\(second_)"
                percentageCompletedLabel.text = "\(minute):\(second)"
                remainingTime = (musicPlayerManager.musicPlayerController.nowPlayingItem?.playbackDuration)! - musicPlayerManager.musicPlayerController.currentPlaybackTime
                endDate = NSDate().addingTimeInterval(remainingTime)
                coundDownTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCountDownLabel), userInfo: nil, repeats: true)
                progressIndicator.value = Float(musicPlayerManager.musicPlayerController.currentPlaybackTime)
                progressIndicator.maximumValue = Float((musicPlayerManager.musicPlayerController.nowPlayingItem?.playbackDuration)!)
            }
        }
    }
    @objc func updateCountDownLabel() {
        percentageRemainingLabel.text = endDate.timeIntervalSinceNow.mmss_
    }
    
    @objc func updateCountUpLabel() {
        percentageCompletedLabel.text = startDate.timeIntervalSinceNow.mmss
    }
    
    func startTimer() {
        if musicPlayerManager.musicPlayerController.playbackState == .playing {
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        coundDownTimer?.invalidate()
    }
    
    
    
    func getSongNames() -> [String] {
        var names = [String]()
        let songs = getSongs()
        for song in songs {
            names.append("\(song.value(forProperty: MPMediaItemPropertyTitle)!)")
        }
        return names
    }
    
    func getSongs() -> [MPMediaItemCollection] {
        let songQuery = MPMediaQuery.songs()
        let songs = songQuery.collections
        if songs != nil {
            return songs!
        }
        else {
            return []
        }
    }
    
    func setSong(song: String) -> Bool {
        var songSet = false
        let songs = getSongs()
        for sng in songs {
            if String(describing: sng.value(forProperty: MPMediaItemPropertyTitle)!) == song {
                musicPlayerManager.musicPlayerController.setQueue(with: sng)
                songSet = true
                break
            }
        }
        return songSet
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums[section].songs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songsCell = tableView.dequeueReusableCell(withIdentifier: "songs") as! SongsTableViewCell
        songsCell.indexPath = indexPath
        songsCell.delegate = self
        songsCell.voteCountLabel.text = "\(songsCell.voteCount)"
        songsCell.songTitleLabel?.text = albums[indexPath.section].songs[indexPath.row].songTitle
        songsCell.artistLabel?.text = albums[indexPath.section].songs[indexPath.row].artistName
        let songID: NSNumber = albums[indexPath.section].songs[indexPath.row].songId
        let item: MPMediaItem = musicQuery.getItem(songId: songID)
        if let artwork: MPMediaItemArtwork = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            songsCell.artworkImage?.image = artwork.image(at: CGSize(width: songsCell.artworkImage.frame.size.width, height: songsCell.artworkImage.frame.size.height))
        }
        
        
        return songsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        
        return indexPath
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: SongsTableViewCellDelegate Method
    func didChangeVoteCount(indexPath: IndexPath) {
        let songID: NSNumber = albums[indexPath.section].songs[indexPath.row].songId
        let item: MPMediaItem = musicQuery.getItem(songId: songID)
        let predicate = MPMediaPropertyPredicate(value: item.persistentID, forProperty: MPMediaItemPropertyPersistentID)
        let query = MPMediaQuery(filterPredicates: [predicate])
        let queueDescriptor = MPMusicPlayerMediaItemQueueDescriptor(query: query)
        musicPlayerManager.musicPlayerController.prepend(queueDescriptor)
        tableView.reloadData()
    }
    
    func changeStatusBarStyle(){
        if self.progressIndicator.minimumTrackTintColor! <= UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1){
            print(self.progressIndicator.minimumTrackTintColor!)
            UINavigationBar.appearance().barStyle = .black
        }
        else {
            UINavigationBar.appearance().barStyle = .default
        }
    }
    
    

    @IBAction func skipAction(_ sender: Any) {
        mainViewController.skipToNextItem()
    }
    
    @IBAction func playAction(_ sender: Any) {
        mainViewController.togglePlayPause()
    }
    
    @IBAction func backwardAction(_ sender: Any) {
        mainViewController.skipBackToBeginningOrPreviousItem()
    }
    
    func updatePlayBackControls() {
        let playbackState = musicPlayerManager.musicPlayerController.playbackState
        switch playbackState {
        case .paused, .stopped, .interrupted:
            playButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            //stopTimer()
            
        case .playing:
            playButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            //startTimer()
        default:
            break
            
        }
    }
    
    @objc func handleMusicPlayerDidChangeState() {
        DispatchQueue.main.async {
            self.updatePlayBackControls()
            self.startTimer()
            self.updateUserInterface()
        }
    }
    
    @objc func handleMusicPlayerNowPlayingItemDidChange() {
        DispatchQueue.main.async {
                self.updateUserInterface()
        }
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


