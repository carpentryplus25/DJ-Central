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

class HostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
    var musicPlayerManager = MusicPlayerManager()
    var mediaItems: MediaItem!
    let imageManager = ImageManager()
    var endDate: NSDate!
    var coundDownTimer = Timer()
    var remainingTime: TimeInterval = 0
    var startDate: NSDate!
    var countUpTimer = Timer()
    var startTime: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        notificationCenter.addObserver(self, selector: #selector(handleMusicPlayerDidChangeState), name: NSNotification.Name.MPMusicPlayerControllerVolumeDidChange, object: nil)
        startTimer()
        updatePlayBackControls()
        update()
        
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
       
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update() {
        let currentItem = musicPlayerManager.musicPlayerController.nowPlayingItem
            guard let artwork = currentItem?.artwork
                else {
                    return
            }
        self.songTitleLabel.text = currentItem?.value(forProperty: MPMediaItemPropertyTitle) as? String
        guard let image = artwork.image(at: self.artWorkImage.frame.size) else {return}
        self.artWorkImage.image = image
        let blurImage = CIImage(image: image)
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(blurImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(25, forKey: kCIInputRadiusKey)
        let context = CIContext()
        let cgImage = context.createCGImage((blurFilter?.outputImage)!, from: (blurImage!.extent))
        let blurredImage = UIImage(cgImage: cgImage!)
        self.blurArtworkImage.image = blurredImage
        let centerPoint = CGPoint(x: self.artWorkImage.center.x, y: self.artWorkImage.center.y)
        self.navigationController?.navigationBar.barTintColor = self.artWorkImage.image?.getPixelColor(centerPoint)
        self.navigationController?.toolbar.barTintColor = self.artWorkImage.image?.getPixelColor(centerPoint)
        self.songTitleLabel.textColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.progressIndicator.minimumTrackTintColor = self.artWorkImage.image?.getPixelColor(centerPoint)
        self.progressIndicator.maximumTrackTintColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.progressIndicator.thumbTintColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.favoriteButton.tintColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.playButton.tintColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.skipButton.tintColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.songTitleLabel.tintColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.percentageCompletedLabel.textColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.percentageRemainingLabel.textColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.playButton.tintColor = self.artWorkImage.image?.inversedColor(centerPoint)
        self.reverseSkip.tintColor = self.artWorkImage.image?.inversedColor(centerPoint)
        
    }
    
    @objc func updateSlider() {
        
        if musicPlayerManager.musicPlayerController.playbackState == .playing {
            guard !(musicPlayerManager.musicPlayerController.currentPlaybackTime.isNaN || musicPlayerManager.musicPlayerController.currentPlaybackTime.isInfinite) else {return}
            let minute_ = Int(musicPlayerManager.musicPlayerController.currentPlaybackTime) / 60
            let second_ = Int(musicPlayerManager.musicPlayerController.currentPlaybackTime.truncatingRemainder(dividingBy: 60))
            let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
            let second = second_ > 9 ? "\(second_)" : "0\(second_)"
            percentageCompletedLabel.text = "\(minute):\(second)"
            /*
            startTime = musicPlayerManager.musicPlayerController.currentPlaybackTime
            startDate = NSDate().addingTimeInterval(startTime)
            countUpTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCountUpLabel), userInfo: nil, repeats: true)
            */
            remainingTime = (musicPlayerManager.musicPlayerController.nowPlayingItem?.playbackDuration)! - musicPlayerManager.musicPlayerController.currentPlaybackTime
            endDate = NSDate().addingTimeInterval(remainingTime)
            coundDownTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCountDownLabel), userInfo: nil, repeats: true)
            progressIndicator.value = Float(musicPlayerManager.musicPlayerController.currentPlaybackTime)
            progressIndicator.maximumValue = Float((musicPlayerManager.musicPlayerController.nowPlayingItem?.playbackDuration)!)
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
        coundDownTimer.invalidate()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let songID: NSNumber = albums[indexPath.section].songs[indexPath.row].songId
        let item: MPMediaItem = musicQuery.getItem(songId: songID)
        musicPlayerManager.musicPlayerController.nowPlayingItem = item
        musicPlayerManager.musicPlayerController.play()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums[section].songs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songsCell = tableView.dequeueReusableCell(withIdentifier: "songs") as! SongsTableViewCell
        songsCell.songTitleLabel?.text = albums[indexPath.section].songs[indexPath.row].songTitle
        songsCell.artistLabel?.text = albums[indexPath.section].songs[indexPath.row].artistName
        let songID: NSNumber = albums[indexPath.section].songs[indexPath.row].songId
        let item: MPMediaItem = musicQuery.getItem(songId: songID)
        if let artwork: MPMediaItemArtwork = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            songsCell.artworkImage?.image = artwork.image(at: CGSize(width: songsCell.artworkImage.frame.size.width, height: songsCell.artworkImage.frame.size.height))
        }
        return songsCell
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
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
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
            
        case .playing:
            playButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            
        default:
            break
            
        }
    }
    
    @objc func handleMusicPlayerDidChangeState() {
        DispatchQueue.main.async {
            self.updatePlayBackControls()
            self.startTimer()
            self.update()
        }
    }
    
    @objc func handleMusicPlayerNowPlayingItemDidChange() {
        DispatchQueue.main.async {
            self.update()
            
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


