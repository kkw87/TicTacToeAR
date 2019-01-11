//
//  Player.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/28/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct Player {
    
    let peerID : MCPeerID
    var userName : String {
        return peerID.displayName
    }
    
    init(peerID : MCPeerID) {
        self.peerID = peerID
    }
    
    init(username : String) {
        self.peerID = MCPeerID(displayName: username)
    }
}

extension Player : Hashable {
    static func ==(lhs : Player, rhs: Player) -> Bool {
        return lhs.peerID == rhs.peerID
    }
}
