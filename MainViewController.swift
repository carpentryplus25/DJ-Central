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

    @IBOutlet weak var hostViewTest: UIView!
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
    var mediaPlayer = MPMusicPlayerController()
    let serviceManger = ServiceManager()
    var hostViewController: HostViewController?
    var interactor = SlideRevealViewInteractor()
    var delegate: SlideRevealViewDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //serviceManger.delegate = self
        
        
        //view.bringSubview(toFront: artWorkImage)
        mediaPlayer = MPMusicPlayerController.systemMusicPlayer
        mediaPlayer.setQueue(with: MPMediaQuery.songs())
        mediaPlayer.play()
        mediaPlayer.beginGeneratingPlaybackNotifications()
        view.bringSubview(toFront: hostView)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let notificationCenter: NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(MainViewController.handleNowPlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    @objc func handleNowPlayingItemChanged(_ notification: NSNotification) {
        if mediaPlayer.playbackState == .playing {
            let currentItem: MPMediaItem = mediaPlayer.nowPlayingItem!
            guard let artwork = currentItem.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                else {
                    return
            }
            let image = artwork.image(at: CGSize(width: 300, height: 300))
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
            print(menuButton.tintColor!)
        
            print("changed")
        }
        else {
            view.sendSubview(toBack: hostView)
            view.bringSubview(toFront: libraryView)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let centerPoint = CGPoint(x: artWorkImage.center.x, y:artWorkImage.center.y)
        if {
            return UIStatusBarStyle.lightContent
        }
        else {
            return UIStatusBarStyle.lightContent
        }
        
        
        
        
    }
    */
    
    func reopenMenu() {
        performSegue(withIdentifier: "slideMenu", sender: nil)
    }
    
    func slideMenu(_ segueName: String, sender: AnyObject?) {
        dismiss(animated: true) {
            self.performSegue(withIdentifier: segueName, sender: sender)
        }
    }
    
    @IBAction func hostAction(_ sender: Any) {
        view.bringSubview(toFront: hostView)
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
    
    
    
    }
    @IBAction func browseHostAction(_ sender: Any) {
        view.bringSubview(toFront: browseHostLibrary)
        view.sendSubview(toBack: favoritesView)
        view.sendSubview(toBack: libraryView)
        view.sendSubview(toBack: hostView)
        view.sendSubview(toBack: nowPlayingView)
    
    
    }
    
    @IBAction func libraryAction(_ sender: Any) {
        view.bringSubview(toFront: libraryView)
        view.sendSubview(toBack: favoritesView)
        view.sendSubview(toBack: browseHostLibrary)
        view.sendSubview(toBack: hostView)
        view.sendSubview(toBack: nowPlayingView)
    
    
    
    }
    
    @IBAction func favoriteAction(_ sender: Any) {
        view.bringSubview(toFront: favoritesView)
        view.sendSubview(toBack: libraryView)
        view.sendSubview(toBack: browseHostLibrary)
        view.sendSubview(toBack: hostView)
        view.sendSubview(toBack: nowPlayingView)
    
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MenuViewController {
            destination.transitioningDelegate = self
            destination.interactor = interactor
            destination.delegate = self
        }
    }
   
    @IBAction func edgePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let progress = SlideRevealViewHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .Down)
        SlideRevealViewHelper.mapGestureStateToInteractor(sender.state, progress: progress, interactor: interactor){
            self.performSegue(withIdentifier: "slideMenu", sender: nil)
            print("hello")
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

/*
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


