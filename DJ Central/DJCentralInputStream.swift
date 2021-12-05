//
//  DJCentralInputStream.swift
//  DJ Central
//
//  Created by William Thompson on 6/10/18.
//  Copyright © 2018 J. W. Enterprises, LLC. All rights reserved.
//

import Foundation
import AudioToolbox

class DJCentralInputStream: NSObject, DJCentralStreamDelegate {
    
    
    //MARK: Properties
    var audioStreamThread: Thread?
    var isPlaying: Bool = false
    var audioStream: DJCentralStream?
    
    //MARK: Initialization
    override init() {
        super.init()
    }
    
    init(inputStream: InputStream) {
        super.init()
        audioStream = DJCentralStream(inputStream: inputStream)
        audioStream?.delegate = self
        inputStream.schedule(in: .current, forMode: RunLoop.Mode.default)
        inputStream.open()
    }
    
    @objc func start() {
        if !Thread.current.isMainThread {
            self.performSelector(onMainThread: #selector(start), with: nil, waitUntilDone: true)
        }
        audioStreamThread = Thread(target: self, selector: #selector(run), object: nil)
        audioStreamThread?.start()
    }
    
    @objc func run() {
        autoreleasepool {
            audioStream?.open()
            isPlaying = true
        }
    }
    
    //MARK: DJCentralStreamDelegate Method
    func audioStream(_ audioStream: DJCentralStream, didRaiseEvent event: DJCentralStreamEvent) {
        switch event {
        case DJCentralStreamEvent.hasData:
            print("has Data")
            //var byte = [UInt8](repeating: 0, count: 512)
            //let lenght = audioStream.readData(&byte, maxLenght: 512)
        case DJCentralStreamEvent.end:
            isPlaying = false
        default:
            break
        }
    }
    
    
    
}
