//
//  UserDefaults.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/29/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct UserDefaultsKeys {
    
    // settings
    static let peerID = "PeerIDDefaultsKey"
}

extension UserDefaults {
    var myself : Player {
        get {
            
            if let data = data(forKey: UserDefaultsKeys.peerID) ,let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data), let peerID = unarchived {
                    return Player(peerID: peerID)
            }
            
            // No existing player found, create new one
            let newPlayer = Player(username: UIDevice.current.name)
            let newData = try? NSKeyedArchiver.archivedData(withRootObject: newPlayer.peerID, requiringSecureCoding: true)
            set(newData, forKey: UserDefaultsKeys.peerID)
            return newPlayer
        } set {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue.peerID, requiringSecureCoding: true)
            set(data, forKey: UserDefaultsKeys.peerID)
        }
    }
}
