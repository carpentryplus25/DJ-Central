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
    
    var mediaPlayer = MPMusicPlayerApplicationController()
    var mainViewController = MainViewController()
    var artWorkImages: [UIImage]!
    var albumTitle: [String]!
    var artistTitle: [String]!
    var songTitle: [String]!
    var timer: Timer?
    var albums: [AlbumInfo] = []
    var musicQuery: MusicQuery = MusicQuery()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.albums = self.musicQuery.get(songCategory: "")
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
            else {
                self.displayMediaLibraryError()
            }
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
        
        
        start()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func start() {
        let notificationCenter: NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleNowPlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleNowPlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: self.mediaPlayer)
        notificationCenter.addObserver(self, selector: #selector(handleNowPlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerVolumeDidChange, object: self.mediaPlayer)
        startTimer()
    }
    
    @objc func handleNowPlayingItemChanged(_ notification: NSNotification) {
        
        guard let currentItem: MPMediaItem = mainViewController.mediaPlayer.nowPlayingItem, let artwork = currentItem.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            else {
             return
        }
        self.songTitleLabel.text = currentItem.value(forProperty: MPMediaItemPropertyTitle) as? String
        let image = artwork.image(at: CGSize(width: 300, height: 300))
        self.artWorkImage.image = image
        let blurImage = CIImage(image: image!)
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
    }
    
    @objc func updateSlider(_ timer: Timer) {
        if mediaPlayer.playbackState == MPMusicPlaybackState.playing {
            let minute_ = abs(Int(mediaPlayer.currentPlaybackTime / 60))
            let second_ = abs(Int(mediaPlayer.currentPlaybackTime.truncatingRemainder(dividingBy: 60)))
            let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
            let second = second_ > 9 ? "\(second_)" : "0\(second_)"
            percentageCompletedLabel.text = "\(minute):\(second)"
            var minutesRemaining_ = abs(Int((mediaPlayer.nowPlayingItem?.playbackDuration)! / 60)) - minute_
            var secondsRemaining_ = abs(Int((mediaPlayer.nowPlayingItem?.playbackDuration.truncatingRemainder(dividingBy: 60))!))
            if secondsRemaining_ >= 00 {
                secondsRemaining_ = secondsRemaining_ - second_
            }
            if secondsRemaining_ <= 00 {
                minutesRemaining_ = minutesRemaining_ - 1
                secondsRemaining_ = 59 - secondsRemaining_ - second_
            }
            let secondsRemaining = secondsRemaining_ > 9 ? "\(secondsRemaining_)" : "0\(secondsRemaining_)"
            let minutesRemaining = minutesRemaining_ > 9 ? "-\(minutesRemaining_) " : "-0\(minutesRemaining_)"
            
            
            percentageRemainingLabel.text = "\(minutesRemaining):\(secondsRemaining)"
            //print(secondsRemaining)
            progressIndicator.value = Float(mediaPlayer.currentPlaybackTime)
            progressIndicator.maximumValue = Float((mediaPlayer.nowPlayingItem?.playbackDuration)!)
            
        }
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let songID = albums[indexPath.section].songs[indexPath.row].songId
        
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

    @IBAction func playAction(_ sender: Any) {
        if mainViewController.mediaPlayer.playbackState == MPMusicPlaybackState.playing {
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
        }
        else {
            playButton.setImage(UIImage(named: "Play"), for: .normal)
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
