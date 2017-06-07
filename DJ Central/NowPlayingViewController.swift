//
//  NowPlayingViewController.swift
//  DJ Central
//
//  Created by William Thompson on 6/4/17.
//  Copyright © 2017 J.W. Enterprises LLC. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreImage

class NowPlayingViewController: UITableViewController {

    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var progressIndicator: UIProgressView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var percentageRemainingLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var cell: UITableViewCell!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var albumArtWorkImage: UIImageView!
    @IBOutlet weak var percentageCompleteLabel: UILabel!
    var musicPlayer = MPMusicPlayerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mediaPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer()
        mediaPlayer.setQueue(with: MPMediaQuery.songs())
        mediaPlayer.play()
        //let mediaPlayback: MPMediaPlayback?
        //progressIndicator.progress = Float(mediaPlayer.currentPlaybackTime)
        let audioInfo = MPNowPlayingInfoCenter.default()
        let artWork = mediaPlayer.nowPlayingItem?.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        let image = artWork?.image(at: CGSize(width: 300, height: 300))
        self.albumArtWorkImage.image = image
        
        //let playerItem
        
        DispatchQueue.main.async {
            
            
            
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let mediaPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer()
        let artWork = mediaPlayer.nowPlayingItem?.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
        let title = mediaPlayer.nowPlayingItem?.value(forProperty: MPMediaItemPropertyTitle)
        let image = artWork?.image(at: CGSize(width: 300, height: 300))
        songTitle.text = title as! String
        self.albumArtWorkImage.image = image
        let blurImage = CIImage(image: image!)
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(blurImage, forKey: "inputImage")
        let outputImage = blurFilter?.value(forKeyPath: "outputImage") as! CIImage
        let context = CIContext()
        let cgImage = context.createCGImage((blurFilter?.outputImage)!, from: (blurFilter?.outputImage?.extent)!)
        let blurredImage = UIImage(cgImage: cgImage!)
        backgroundImage.image = blurredImage
        let centerPoint = CGPoint(x: self.albumArtWorkImage.center.x, y: self.albumArtWorkImage.center.y)
        self.navigationController?.navigationBar.barTintColor = self.albumArtWorkImage.image?.getPixelColor(centerPoint)
        self.navigationController?.toolbar.barTintColor = self.albumArtWorkImage.image?.getPixelColor(centerPoint)
        progressIndicator.trackTintColor = self.albumArtWorkImage.image?.getPixelColor(centerPoint)
        progressIndicator.progressTintColor = self.albumArtWorkImage.image?.inversedColor(centerPoint)
        favoriteButton.tintColor = self.albumArtWorkImage.image?.inversedColor(centerPoint)
        skipButton.tintColor = self.albumArtWorkImage.image?.inversedColor(centerPoint)
        songTitle.textColor = self.albumArtWorkImage.image?.inversedColor(centerPoint)
        percentageCompleteLabel.textColor = self.albumArtWorkImage.image?.inversedColor(centerPoint)
        percentageRemainingLabel.textColor = self.albumArtWorkImage.image?.inversedColor(centerPoint)
        UIBarButtonItem.appearance().tintColor = self.albumArtWorkImage.image?.inversedColor(centerPoint)
        menuButton.tintColor = self.albumArtWorkImage.image?.inversedColor(centerPoint)
        searchButton.tintColor = self.albumArtWorkImage.image?.inversedColor(centerPoint)
        
        
        
        
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.barTintColor = self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: view.center.x, y: view.center.y))
        //self.navigationController?.toolbar.barTintColor = self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: view.center.x, y: view.center.y))
        progressIndicator.trackTintColor = self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: self.albumArtWorkImage.center.x, y: self.albumArtWorkImage.center.y))
        progressIndicator.progressTintColor = inverseColor(color: (self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: self.albumArtWorkImage.center.x, y: self.albumArtWorkImage.center.y)))!
        )
        favoriteButton.tintColor = inverseColor(color: (self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: self.albumArtWorkImage.center.x, y: self.albumArtWorkImage.center.y)))!)
        skipButton.tintColor = inverseColor(color: (self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: self.albumArtWorkImage.center.x, y: self.albumArtWorkImage.center.y)))!)
        songTitle.textColor = inverseColor(color: (self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: self.albumArtWorkImage.center.x, y: self.albumArtWorkImage.center.y)))!)
        percentageCompleteLabel.textColor = inverseColor(color: (self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: self.albumArtWorkImage.center.x, y: self.albumArtWorkImage.center.y)))!)
        percentageRemainingLabel.textColor = inverseColor(color: (self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: view.center.x, y: view.center.y)))!)
        UIBarButtonItem.appearance().tintColor = inverseColor(color: (self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: view.center.x, y: view.center.y)))!)
        menuButton.tintColor = inverseColor(color: (self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: self.albumArtWorkImage.center.x, y: self.albumArtWorkImage.center.y)))!)
        searchButton.tintColor = inverseColor(color: (self.albumArtWorkImage.image?.getPixelColor(CGPoint(x: self.albumArtWorkImage.center.x, y: self.albumArtWorkImage.center.y)))!)
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createARGBBitmapContext(_ inImage: CGImage) -> CGContext {
        var bitmapByteCount = 0
        var bitmapBytesPerRow = 0
        let pixelsWide = inImage.width
        let pixelsHigh = inImage.height
        bitmapBytesPerRow = Int(pixelsWide) * 4
        bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = malloc(bitmapByteCount)
        let context = CGContext(data: bitmapData, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        return context!
    }
    
    
    
    

    func updateProgressIndicator () {
        
    }
    
    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    
    func createARGBBitmapContext(_ inImage: CGImage) -> CGContext {
        var bitmapByteCount = 0
        var bitmapBytesPerRow = 0
        let pixelsWide = inImage.width
        let pixelsHigh = inImage.height
        bitmapBytesPerRow = Int(pixelsWide) * 4
        bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = malloc(bitmapByteCount)
        let context = CGContext(data: bitmapData, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        return context!
    }
    
    func getPixelColor(_ point: CGPoint) -> UIColor {
        let provider = self.cgImage?.dataProvider
        let pixelData = provider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        print("color is r: \(r) g: \(g) b: \(b) a: \(a)")
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func inversedColor(_ point: CGPoint) -> UIColor {
        let provider = self.cgImage?.dataProvider
        let pixelData = provider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        print("inversedcolor is r: \(1.0 - r) g: \(1.0 - g) b: \(1.0 - b) a: \(a)")
        return UIColor(red: 1.0 - r , green: 1.0 - g, blue: 1.0 - b, alpha: a)
    }
    
    
    
}
