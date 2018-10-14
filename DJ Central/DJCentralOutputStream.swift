//
//  DJCentralOutputStream.swift
//  DJ Central
//
//  Created by William Thompson on 6/10/18.
//  Copyright © 2018 J. W. Enterprises, LLC. All rights reserved.
//

import Foundation
import AVFoundation

class DJCentralOutputStream: NSObject, DJCentralStreamDelegate {
    
    //MARK: Properties
    var audioStream: DJCentralStream?
    var assetReader: AVAssetReader?
    var assetReaderTrackOutput: AVAssetReaderTrackOutput?
    var streamThread: Thread?
    var isStreaming: Bool = false
    
    //MARK: Initilization
    init(outputStream stream: OutputStream) {
        super.init()
        audioStream = DJCentralStream(outputStream: stream)
        audioStream?.delegate = self
    }
    
    @objc func start() {
        if !Thread.current.isEqual(Thread.main) {
            return performSelector(onMainThread: #selector(start), with: nil, waitUntilDone: true)
        }
        streamThread = Thread(target: self, selector: #selector(run), object: nil)
        streamThread?.start()
    }
    
    @objc func run() {
        autoreleasepool {
            audioStream?.open()
            isStreaming = true
            print("Loop")
            while isStreaming && RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantFuture) {
                print("Done")
            }
        }
    }
    
    func streamAudio(from url: URL) {
        let asset: AVURLAsset = AVURLAsset(url: url, options: nil)
        do {
            try? assetReader = AVAssetReader(asset: asset)
        }
        assetReaderTrackOutput = AVAssetReaderTrackOutput(track: asset.tracks[0], outputSettings: nil)
        if !((assetReader?.canAdd(assetReaderTrackOutput!))!) {
            return
        }
        assetReader?.add(assetReaderTrackOutput!)
        assetReader?.startReading()
    }
    
    func sendChunkData() {
        var sampleBuffer: CMSampleBuffer?
        sampleBuffer = assetReaderTrackOutput?.copyNextSampleBuffer()
        if (sampleBuffer == nil || CMSampleBufferGetNumSamples(sampleBuffer!) == 0) {
            return
        }
        var blockBuffer: CMBlockBuffer?
        var audioBufferList = AudioBufferList()
        let err: OSStatus? = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer!, nil, &audioBufferList, MemoryLayout<AudioBufferList>.size, nil, nil, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer)
        if err == nil {
            return
        }
        for _ in UInt32(0)..<audioBufferList.mNumberBuffers {
            print(audioBufferList.mNumberBuffers)
            let audioBuffer: AudioBuffer = audioBufferList.mBuffers
            let mData: UnsafeMutablePointer = (audioBuffer.mData?.assumingMemoryBound(to: UInt8.self))!
            print(audioBuffer)
            let write = audioStream?.writeData(mData, maxLength: audioBuffer.mDataByteSize)
            print(write!)
            //print("buffer size: \(UInt(audioBuffer.mDataByteSize))")
        }
    }
    
    func stop() {
        perform(#selector(stopThread), on: streamThread!, with: nil, waitUntilDone: true)
    }
    
    @objc func stopThread() {
        isStreaming = false
        audioStream?.close()
    }
    
    //MARK: DJCentralStreamDelegate Methods
    func audioStream(_ audioStream: DJCentralStream, didRaiseEvent event: DJCentralStreamEvent) {
        switch event {
        case DJCentralStreamEvent.wantsData:
            sendChunkData()
            print("wants data")
        case DJCentralStreamEvent.error:
            print("Stream Error")
        case DJCentralStreamEvent.end:
            print("Stream Ended")
        default:
            break
            
        }
    }
    
}
