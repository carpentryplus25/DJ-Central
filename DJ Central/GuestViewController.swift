//
//  GuestViewController.swift
//  DJ Central
//
//  Created by William Thompson on 7/18/18.
//  Copyright © 2018 Joseph Thompson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GuestViewController: UIViewController, DJCentralSessionDelegate {
    
    
    @IBOutlet weak var artworkImage: UIImageView!
    
    @IBOutlet weak var blurArtworkImage: UIImageView!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var session: DJCentralSession?
    var inputStream = DJCentralInputStream()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = DJCentralSession(peerDisplayName: UIDevice.current.name)
        session?.startAdvertising(forServiceType: "DJ-Central", discoveryInfo: nil)
        session?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        session?.stopAdvertising()
    }
    
    @objc func changeSongInfo(info: [AnyHashable: Any]) {
        print("called session didRecieveData delegate method")
        let color = info["color"] as? UIColor
        let inversedColor = info["inversedColor"] as? UIColor
        navigationController?.navigationBar.barTintColor = color
        navigationController?.toolbar.barTintColor = color
        navigationController?.navigationItem.backBarButtonItem?.tintColor = inversedColor
        UIBarButtonItem.appearance().tintColor = inversedColor
        tabBarController?.tabBar.barTintColor = color
        songTitleLabel.textColor = inversedColor
        if (info["artwork"] != nil ) {
            let image = info["artwork"] as? UIImage
            artworkImage.image = image
            let blurImage = CIImage(image: image!)
            let blurFilter = CIFilter(name: "CIGaussianBlur")
            blurFilter?.setValue(blurImage, forKey: kCIInputImageKey)
            blurFilter?.setValue(25, forKey: kCIInputRadiusKey)
            let context = CIContext()
            let cgImage = context.createCGImage((blurFilter?.outputImage)!, from: blurImage!.extent)
            let blurredImage = UIImage(cgImage: cgImage!)
            blurArtworkImage.image = blurredImage
            songTitleLabel.text = info["title"] as? String
            //let color = info["color"] as? UIColor
            //let inversedColor = info["inversedColor"] as? UIColor
            
            //changeColors(info: info)
        }
        else {
            let image = UIImage(named: "Album_Art")
            artworkImage.image = image
            let blurImage = CIImage(image: image!)
            let blurFilter = CIFilter(name: "CIGaussianBlur")
            blurFilter?.setValue(blurImage, forKey: kCIInputImageKey)
            blurFilter?.setValue(25, forKey: kCIInputRadiusKey)
            let context = CIContext()
            let cgImage = context.createCGImage((blurFilter?.outputImage)!, from: blurImage!.extent)
            let blurredImage = UIImage(cgImage: cgImage!)
            blurArtworkImage.image = blurredImage
            songTitleLabel.text = " "
            //changeColors(info: info)
        }
    }
    
    func changeColors(info: [AnyHashable: Any]) {
        let color = info["color"] as? UIColor
        let inversedColor = info["inversedColor"] as? UIColor
        
        //let centerPoint = CGPoint(x: artworkImage.center.x, y: artworkImage.center.y)
        navigationController?.navigationBar.barTintColor = color
        navigationController?.toolbar.barTintColor = color
        tabBarController?.tabBar.barTintColor = color
        //let inversedColor = artworkImage.image?.inversedColor(centerPoint)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: inversedColor as Any], for: .normal)
    }
    
    //MARK: - DJCentralSessionDelegate Methods
    func session(_ session: DJCentralSession, didReceiveAudioStream stream: InputStream) {
        inputStream = DJCentralInputStream(inputStream: stream)
        inputStream.start()
    }
    
    func session(_ session: DJCentralSession, didReceive data: Data) {
        let info: NSDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
        print("called session didRecieveData delegate method")
        performSelector(onMainThread: #selector(changeSongInfo), with: info, waitUntilDone: false)
    }
    
    func session(_ session: DJCentralSession, didFinishConnecting toPeer: MCPeerID) {
        performSelector(onMainThread: #selector(changeSongInfo), with: nil, waitUntilDone: false)
    }
    
    func session(_ session: DJCentralSession, holdData: Data) {
        let info = NSKeyedUnarchiver.unarchiveObject(with: holdData)
        performSelector(onMainThread: #selector(changeSongInfo), with: info, waitUntilDone: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
