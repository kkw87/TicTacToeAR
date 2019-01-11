//
//  MultipeerHostSessionViewModel.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/25/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import MultipeerConnectivity
import ARKit

protocol MultipeerNetworkSessionViewModelDelegate {
    
    func networkSession(received command: PlayerMove)
    func networkSession(received worldTrackingConfiguration : ARWorldTrackingConfiguration)
    func networkSession(received gameState : TicTacToe)
    func networkSession(joining player: Player)
    func networkSession(leaving player: Player)
    
}

protocol MultipeerNetworkSessionViewModelDataSource {
    func gamesUpdated()
}

private let maxPeers = 2

class MultipeerNetworkSessionViewModel : NSObject {
    
    struct Constants {
        static let ConnectionTimeout : Double = 30
    }
    
    // MARK: - Model
    private let hostSession : MCSession
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    // MARK: - Instance Variables
    let myself : Player
    
    var isServer : Bool {
        didSet {
            myGamePiece = isServer ? GamePiece.X : GamePiece.O
        }
    }
    
    private(set) var games : [GameToJoin] = [] {
        didSet {
            dataSource?.gamesUpdated()
        }
    }
    
    var delegate : MultipeerNetworkSessionViewModelDelegate?
    var dataSource : MultipeerNetworkSessionViewModelDataSource?
    
    private var currentPlayers : Set<Player> = []
 
    private var myGamePiece : GamePiece
    // TODO: - Make a variable to determine whose turn it is
    
    // MARK: - Inits
    init(myself : Player, server : Bool) {
        
        self.myself = myself
        self.isServer = server
        
        self.myGamePiece = server ? GamePiece.X : GamePiece.O
        
        hostSession = MCSession(peer: myself.peerID, securityIdentity: nil, encryptionPreference: .required)
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myself.peerID, discoveryInfo: nil, serviceType: MultipeerConstants.playerService)
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myself.peerID, serviceType: MultipeerConstants.playerService)
        
        super.init()
        
        hostSession.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self

    }
    
    // MARK: - Data sending functions
    func send(data : Data) {
        do {
            try hostSession.send(data, toPeers: hostSession.connectedPeers, with: .reliable)
        } catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Advertising functions
    func startAdvertising() {
        serviceBrowser.stopBrowsingForPeers()
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        serviceAdvertiser.stopAdvertisingPeer()

        serviceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func join(game : GameToJoin) {
        
        guard games.contains(game) else {
            return
        }
        
        serviceBrowser.invitePeer(game.host.peerID, to: hostSession, withContext: nil, timeout: Constants.ConnectionTimeout)
        
    }
    
    func isMyTurn(currentPlayerTurn : GamePiece) -> Bool {
        if currentPlayers.count < maxPeers || currentPlayerTurn == myGamePiece {
            return true
        } else {
            return false
        }
    }
}

extension MultipeerNetworkSessionViewModel : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        let player = Player(peerID: peerID)
        
        switch state {
        case .connected :
            currentPlayers.insert(player)
            delegate?.networkSession(joining: player)
        case .connecting :
            break
        case .notConnected :
            currentPlayers.remove(player)
            delegate?.networkSession(leaving: player)
        }
        

        if currentPlayers.count >= maxPeers {
            stopAdvertising()
            stopBrowsing()
        } else {
            startAdvertising()
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        if let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.initialWorldMap = worldMap
            delegate?.networkSession(received: configuration)
            
        } else if let playerMove = try? NSKeyedUnarchiver.unarchivedObject(ofClass: PlayerMove.self, from: data) {
            delegate?.networkSession(received: playerMove!)
        } else if let gameState = try? NSKeyedUnarchiver.unarchivedObject(ofClass: TicTacToe.self, from: data) {
            delegate?.networkSession(received: gameState!)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension MultipeerNetworkSessionViewModel : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
                
        if currentPlayers.count >= 2 {
            invitationHandler(false, nil)
        } else {
            invitationHandler(true, hostSession)
        }
        
    }
}

extension MultipeerNetworkSessionViewModel : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        guard peerID != myself.peerID else {
            return
        }
        
        let player = Player(peerID: peerID)
        
        let foundGame = GameToJoin(host: player)
        games.append(foundGame)
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {

    }
    
    
}
