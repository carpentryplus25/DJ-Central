//
//  MainViewController.swift
//  DJ Central
//
//  Created by Thompson on 6/8/17.
//  Copyright © 2017 Joseph Thompson. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController {

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
    var mediaPlayer = MPMusicPlayerApplicationController()
    let serviceManger = ServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceManger.delegate = self
        view.bringSubview(toFront: hostView)
        mediaPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer()
        mediaPlayer.setQueue(with: MPMediaQuery.songs())
        mediaPlayer.play()
        mediaPlayer.beginGeneratingPlaybackNotifications()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let notificationCenter: NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(MainViewController.handleNowPlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    func handleNowPlayingItemChanged(_ notification: NSNotification) {
        let currentItem: MPMediaItem = mediaPlayer.nowPlayingItem!
        guard let artwork = currentItem.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            else {
                return
        }
        let image = artwork.image(at: CGSize(width: 300, height: 300))
        self.artWorkImage.image = image
        let centerPoint = CGPoint(x: artWorkImage.center.x, y:artWorkImage.center.y)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
   
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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



