//
//  ViewController.swift
//  DJ Central
//
//  Created by William Thompson on 6/3/17.
//  Copyright © 2017 J.W. Enterprises LLC. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    var musicPlayer = AVAudioPlayer()
    let serviceManager = ServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceManager.delegate = self

        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func change(color : UIColor) {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = color
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

extension ViewController: ServiceManagerDelegate {
    func connectedDevicesChanged(manager: ServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            
        }
    }
    
    func colorChanged(manager: ServiceManager, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "red":
                self.change(color: .red)
            case "yellow":
                self.change(color: .yellow)
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
    
}
