//
//  MainViewController.swift
//  DJ Central
//
//  Created by William Thompson on 6/8/17.
//  Copyright © 2017 J.W Enterprises, LLC. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController, SlideRevealViewDelegate {

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
    let serviceManger = ServiceManager()
    var hostViewController: HostViewController?
    var interactor = SlideRevealViewInteractor()
    var delegate: SlideRevealViewDelegate? = nil
    var appleMusicManager = AppleMusicManager()
    var musicPlayerManager = MusicPlayerManager()
    var menuViewController = MenuViewController()
    var isSearchPresented: Bool = false
    var searchAppleMusicTableViewController: SearchAppleMusicTableViewController!
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
        updateInterface()
        NotificationCenter.default.addObserver(self,selector: #selector(handleMusicPlayerManagerDidUpdateState),name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMusicPlayerManagerDidUpdateState), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        authorizationManager.requestCloudServiceCapabilities()
    }
    
    func updateInterface() {
            let currentItem = musicPlayerManager.musicPlayerController.nowPlayingItem
            guard let artwork = currentItem?.artwork
                else {
                    return
            }
            let image = artwork.image(at: self.artWorkImage.frame.size)
            self.artWorkImage.image = image
            let centerPoint = CGPoint(x: artWorkImage.center.x, y: artWorkImage.center.y)
            UIBarButtonItem.appearance().tintColor = artWorkImage.image?.inversedColor(centerPoint)
            menuButton.tintColor = artWorkImage.image?.inversedColor(centerPoint)
            searchButton.tintColor = artWorkImage.image?.inversedColor(centerPoint)
            favoritesButton.tintColor = artWorkImage.image?.inversedColor(centerPoint)
            hostButton.tintColor = artWorkImage.image?.inversedColor(centerPoint)
            browseButton.tintColor = artWorkImage.image?.inversedColor(centerPoint)
            nowPlayingButton.tintColor = artWorkImage.image?.inversedColor(centerPoint)
            libraryButton.tintColor = artWorkImage.image?.inversedColor(centerPoint)
            changeStatusBarStyle()
            print("changed")
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if menuButton.tintColor! >= (artWorkImage.image?.getPixelColor(centerPoint))!{
            self.navigationController?.navigationBar.barStyle = .black
        }
        else {
            self.navigationController?.navigationBar.barStyle = .default
        }
    }
    
    func reopenMenu() {
        performSegue(withIdentifier: "slideMenu", sender: nil)
    }
    
    func slideMenu(_ segueName: String, sender: AnyObject?) {
        dismiss(animated: true) {
            self.performSegue(withIdentifier: segueName, sender: sender)
        }
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        if isSearchPresented == true {
            searchAppleMusicTableViewController = SearchAppleMusicTableViewController()
            searchAppleMusicTableViewController.searchController.isActive = false
            self.performSegue(withIdentifier: "slideMenu", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "slideMenu", sender: nil)
        }
    }
    
    @IBAction func hostAction(_ sender: Any) {
        view.bringSubview(toFront: hostView)
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
        dismiss(animated: true) {
            self.delay(seconds: 0.5) {
                
                    self.reopenMenu()
                
            }
        }
    }
    
    @objc func handleMusicPlayerManagerDidUpdateState() {
        DispatchQueue.main.async {
            self.updateInterface()
            self.changeStatusBarStyle()
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

/* // Removed for now til I can figure out exactly how I want to implement this
extension MainViewController: ServiceManagerDelegate {
    func connectedDevicesChanged(manager: ServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            
        }
    }
    
    func colorChanged(manager: ServiceManager, colorString: String) {
        OperationQueue.main.addOperation {
            
        }
    }
}
*/


