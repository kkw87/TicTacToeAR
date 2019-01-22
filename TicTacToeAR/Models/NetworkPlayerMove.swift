//
//  NetworkPlayerMove.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 1/15/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import UIKit

class NetworkPlayerMove: NSObject, NSCoding {
    
    struct CodingKeys {
        static let PlayerMoveKey = "playerMove"
        static let TappedNodeKey = "tappedNode"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(playerMove, forKey: CodingKeys.PlayerMoveKey)
        aCoder.encode(tappedNode, forKey: CodingKeys.TappedNodeKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        playerMove = aDecoder.decodeObject(of: PlayerMove.self, forKey: CodingKeys.PlayerMoveKey)!
        tappedNode = aDecoder.decodeObject(of: GridNode.self, forKey: CodingKeys.TappedNodeKey)!
    }
    
    
    let playerMove : PlayerMove
    let tappedNode : GridNode
    
    init(playerMove : PlayerMove, tappedNode : GridNode) {
        self.playerMove = playerMove
        self.tappedNode = tappedNode
        
        super.init()
    }
    
    

}
