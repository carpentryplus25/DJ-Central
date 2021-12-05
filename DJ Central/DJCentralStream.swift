//
//  DJCentralStream.swift
//  DJ Central
//
//  Created by William Thompson on 6/11/18.
//  Copyright © 2018 J. W. Enterprises, LLC. All rights reserved.
//

import Foundation

enum DJCentralStreamEvent: Int {
    case hasData
    case wantsData
    case end
    case error
}

protocol DJCentralStreamDelegate: NSObjectProtocol {
    func audioStream(_ audioStream: DJCentralStream, didRaiseEvent event: DJCentralStreamEvent)
}

class DJCentralStream: NSObject, StreamDelegate {
    
    
    weak var delegate: DJCentralStreamDelegate!
    var stream: Stream?
    
    //MARK: Initilization
    init(inputStream: InputStream) {
        super.init()
        stream = inputStream
    }
    
    init(outputStream: OutputStream) {
        super.init()
        stream = outputStream
    }
    
    func open() {
        stream?.delegate = self
        stream?.schedule(in: .current, forMode: RunLoop.Mode.default)
        stream?.open()
    }
    
    func close() {
        stream?.close()
        stream?.delegate = nil
        stream?.remove(from: .current, forMode: RunLoop.Mode.default)
    }
    
    func readData(_ data: UnsafeMutablePointer<UInt8>, maxLenght: Int) -> UInt32 {
        return UInt32((stream as! InputStream).read(data, maxLength: Int(maxLenght)))
    }
    
    func writeData(_ data: UnsafeMutablePointer<UInt8>, maxLength: UInt32) -> UInt32 {
        return (UInt32(((stream as? OutputStream)?.write(data, maxLength: Int(maxLength)))!))
    }
    /*
    func dealloc() {
        if stream != nil {
            close()
        }
    }
    */
    //MARK: StreamDelegate method
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            delegate.audioStream(self, didRaiseEvent: DJCentralStreamEvent.hasData)
            
        case .hasSpaceAvailable:
            delegate.audioStream(self, didRaiseEvent: DJCentralStreamEvent.wantsData)
            print("wantsData")
        case .endEncountered:
            delegate.audioStream(self, didRaiseEvent: DJCentralStreamEvent.end)
            print("end")
        case .errorOccurred:
            delegate.audioStream(self, didRaiseEvent: DJCentralStreamEvent.error)
            print("error")
        default:
            break
        }
    }
    
}
