//
//  MultipeerHostSessionViewModel.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/25/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import MultipeerConnectivity
import ARKit


// MARK: - MultipeerNetworkSessionViewModelDelegate declaration
protocol MultipeerNetworkSessionViewModelDelegate {
    
    func networkSession(received command: PlayerMove)
    func networkSession(received worldConfiguration : ARWorldTrackingConfiguration)
    func networkSession(received gameBoardState : GameBoardState)
    func networkSession(received gameState : GameData)
    func networkSession(joining player: Player)
    func networkSession(leaving player: Player)
}

// MARK: - MultipeerNetworkSessionViewModelDataSource declaration
protocol MultipeerNetworkSessionViewModelDataSource {
    func gamesUpdated()
}

private let maxPeers = 2

class MultipeerNetworkSessionViewModel : NSObject {
    
    // MARK: - Constants
    struct Constants {
        static let ConnectionTimeout : Double = 10
    }
    
    // MARK: - Model
    private let mainSession : MCSession
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    // MARK: - Instance Variables
    let myself : Player
    
    var isMyTurn : Bool = true
    
    var otherConnectedPlayers : Bool {
        return mainSession.connectedPeers.count > 0
    }
    
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
    
    private let jsonDecoder = JSONDecoder()
    
    var delegate : MultipeerNetworkSessionViewModelDelegate?
    var dataSource : MultipeerNetworkSessionViewModelDataSource?
    
    private(set) var myGamePiece : String
    
    // MARK: - Inits
    init(myself : Player, server : Bool) {
        
        self.myself = myself
        self.isServer = server
        
        self.myGamePiece = server ? GamePiece.X : GamePiece.O
        
        mainSession = MCSession(peer: myself.peerID, securityIdentity: nil, encryptionPreference: .required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myself.peerID, discoveryInfo: nil, serviceType: MultipeerConstants.playerService)
        serviceBrowser = MCNearbyServiceBrowser(peer: myself.peerID, serviceType: MultipeerConstants.playerService)
        
        super.init()
        
        mainSession.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    // MARK: - Data sending functions
    func send(data : Data) {
        
        guard mainSession.connectedPeers.count > 0 else {
            return
        }
        
        do {
            try mainSession.send(data, toPeers: mainSession.connectedPeers, with: .reliable)
            } catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Leave game
    func leaveGame() {
        if isServer {
            stopAdvertising()
        } else {
            mainSession.disconnect()
            startBrowsing()
        }
    }
    
    // MARK: - Advertising functions
    func startAdvertising() {
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        serviceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func join(game : GameToJoin) {
        
        guard games.contains(game) else {
            return
        }
        
        serviceBrowser.invitePeer(game.host.peerID, to: mainSession, withContext: nil, timeout: Constants.ConnectionTimeout)
    }
    
}

// MARK: - MCSession Delegate
extension MultipeerNetworkSessionViewModel : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let player = Player(peerID: peerID)
        
        switch state {
        case .connected :
            delegate?.networkSession(joining: player)
        case .connecting :
            break
        case .notConnected :
            delegate?.networkSession(leaving: player)
        }
        
        if mainSession.connectedPeers.count >= maxPeers {
            stopAdvertising()
            stopBrowsing()
        } else {
            startAdvertising()
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        if let gameData = try? jsonDecoder.decode(GameData.self, from: data) {
            delegate?.networkSession(received: gameData)
        }
        
        if let gameBoardState = try? jsonDecoder.decode(GameBoardState.self, from: data) {
            delegate?.networkSession(received: gameBoardState)
        }
        
        if let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.initialWorldMap = worldMap
            delegate?.networkSession(received: configuration)
        }
        
        if let playerMove = try? jsonDecoder.decode(PlayerMove.self, from: data) {
            isMyTurn = true
            delegate?.networkSession(received: playerMove)
        } 
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

// MARK: - MCNearbyService Advertiser Delegate
extension MultipeerNetworkSessionViewModel : MCNearbyServiceAdvertiserDelegate {
    
    //The host will begin advertising, the host will "join" the other player's session
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        if mainSession.connectedPeers.count >= 2 {
            invitationHandler(false, nil)
        } else {
            invitationHandler(true,mainSession)
        }
        
    }
}

// MARK: - MCNearbyService Browser Delegate

//Found a host, we invite the host to join our session
extension MultipeerNetworkSessionViewModel : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        let player = Player(peerID: peerID)
        
        let foundGame = GameToJoin(host: player)
        games.append(foundGame)
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let gameToRemove = games.first {
            $0.host.peerID == peerID
        }
        
        games = games.filter {
            $0 != gameToRemove
        }
    }
    
    
}
