//
//  CurrentGameData.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 1/13/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import UIKit

class CurrentGameData : NSObject, NSCoding {
    
    struct CodingKeys {
        static let GameState = "gameState"
        static let CurrentGame = "currentGame"
        static let BoardPlaced = "boardPlaced"
        static let BoardPlaneFound = "boardPlaneFound"
    }
    
    func encode(with aCoder: NSCoder) {
        try? (aCoder as! NSKeyedArchiver).encodeEncodable(gameState, forKey: CodingKeys.GameState)
        aCoder.encode(currentGame, forKey: CodingKeys.CurrentGame)
        aCoder.encode(boardPlaced, forKey: CodingKeys.BoardPlaced)
        aCoder.encode(boardPlaneFound, forKey: CodingKeys.BoardPlaneFound)
    }
    
    required init?(coder aDecoder: NSCoder) {
        gameState = (aDecoder as! NSKeyedUnarchiver).decodeDecodable(GameState.self, forKey: CodingKeys.GameState)!
        currentGame = aDecoder.decodeObject(of: TicTacToe.self, forKey: CodingKeys.CurrentGame)!
        boardPlaced = aDecoder.decodeBool(forKey: CodingKeys.BoardPlaced)
        boardPlaneFound = aDecoder.decodeBool(forKey: CodingKeys.BoardPlaneFound)
    }
    
    let gameState : GameState
    let currentGame : TicTacToe
    let boardPlaced : Bool
    var boardPlaneFound : Bool
    
    init(gameState : GameState, gameModel : TicTacToe, boardPlaced : Bool, planeFound : Bool) {
        self.gameState = gameState
        self.currentGame = gameModel
        self.boardPlaced = boardPlaced
        self.boardPlaneFound = planeFound
        
        super.init()
    }
}
