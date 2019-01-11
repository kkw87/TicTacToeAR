//
//  GameToJoin.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/28/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct GameToJoin: Hashable {
    
    var name : String
    var host: Player
    
    init(host : Player, name : String? = nil) {
        self.host = host
        self.name = name ?? "\(host.userName)'s game"
    }
}
