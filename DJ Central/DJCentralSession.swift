//
//  DJCentralSession.swift
//  DJ Central
//
//  Created by William Thompson on 6/10/18.
//  Copyright © 2018 J. W. Enterprises, LLC. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol DJCentralSessionDelegate {
    func session(_ session: DJCentralSession, didReceiveAudioStream stream: InputStream)
    func session(_ session: DJCentralSession, didReceive data: Data)
    func session(_ session: DJCentralSession, didFinishConnecting toPeer: MCPeerID)
    func session(_ session: DJCentralSession, holdData: Data)
}

class DJCentralSession: NSObject, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceBrowserDelegate {
    
    var delegate: DJCentralSessionDelegate?
    
    var advertiser: MCAdvertiserAssistant?
    var serviceType = "DJ-Central"
    var peerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    var serviceBrowser: MCNearbyServiceBrowser!
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        return session
    }()
    
    func _session() -> MCSession {
        
        session = MCSession(peer: peerID)
        session.delegate = self
        
        return session
    }
    
    override init() {
        super.init()
        advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
    }
    
    init(peerDisplayName name: String) {
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        self.serviceBrowser.startBrowsingForPeers()
        super.init()
        self.serviceBrowser.delegate = self
        //self.session.delegate = self
        peerID = MCPeerID(displayName: name)
    }
    
    func send(_ data: Data) {
        print("sending data")
        let error: Error? = nil
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        delegate?.session(self, holdData: data)
        if error != nil {
            //print("Error: \(String(describing: (error as NSError?)?.userInfo.description))")
        }
        
    }
    
    func outputStream(forPeer peer: MCPeerID) -> OutputStream {
        let error: Error? = nil
        let stream: OutputStream? = try? session.startStream(withName: "music", toPeer: peer)
        if error != nil {
            //print("Error: \(String(describing: (error as NSError?)?.userInfo.description))")
        }
        return stream!
        
    }
    
    func connectedPeers() -> [MCPeerID] {
        return (session.connectedPeers)
    }
    
    func browserViewController(forSeriviceType type: String) -> MCBrowserViewController {
        let view = MCBrowserViewController(serviceType: type, session: session)
        view.delegate = self
        return view
    }
    
    //MARK: MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    
    //MARK: MCBrowserViewControllerDelegate
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    //MARK: MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connecting {
            print("Connecting to \(peerID.displayName)")
        }
        else if state == .connected {
            delegate?.session(self, didFinishConnecting: peerID)
        }
        else if state == .notConnected {
            //print("Disconnected from \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate!.session(self, didReceive: data)
        print("called DJCentralSession Delegate didRecieve data")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        if (streamName == "music") {
            delegate!.session(self, didReceiveAudioStream: stream)
        }
    }
    
    func startAdvertising(forServiceType type: String, discoveryInfo info: [String : String]?) {
        advertiser = MCAdvertiserAssistant(serviceType: type, discoveryInfo: info, session: session)
        advertiser?.start()
    }
    
    func stopAdvertising() {
        advertiser?.stop()
    }
    
    //MARK: Unused delegate methods required for protocol conformance
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
}
