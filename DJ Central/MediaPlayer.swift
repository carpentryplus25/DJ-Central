//
//  MediaPlayer.swift
//  DJ Central
//
//  Created by Thompson on 6/8/17.
//  Copyright © 2017 Joseph Thompson. All rights reserved.
//

import UIKit
import MediaPlayer

class MediaPlayer: NSObject , MPMediaPlayback{

    func play() {
        
    }
    
    func pause() {
        
    }
    
    func stop() {
        
    }
    
    func prepareToPlay() {
        
    }
    
    override init() {
        super.init()
    }
    
    var isPreparedToPlay: Bool = false
    
    func beginSeekingForward() {
        
    }
    
    func beginSeekingBackward() {
        
    }
    
    func endSeeking() {
        
    }
    
    var currentPlaybackRate: Float = 0.0
    
    var currentPlaybackTime: TimeInterval = 0.0
    
    
    
}

extension NSNotification.Name {
    
}

