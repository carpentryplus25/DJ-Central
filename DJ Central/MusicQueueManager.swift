//
//  MusicQueueManager.swift
//  DJ Central
//
//  Created by William Thompson on 6/19/20.
//  Copyright © 2020 J.W. Enterprises LLC. All rights reserved.
//

import Foundation
import MediaPlayer

protocol MusicQueueManagerDelegate {
    func willInsertMediaItem(_: MPMusicPlayerQueueDescriptor, after: MPMediaItem?)
    func didInsertMediaItem(_: MPMusicPlayerQueueDescriptor, after: MPMediaItem?)
    func willRemove(mediaItem: MPMediaItem)
    func didRemove(mediaItem: MPMediaItem)
    
}

class MusicQueueManager : MPMusicPlayerControllerMutableQueue {
    
    
    
    
}


