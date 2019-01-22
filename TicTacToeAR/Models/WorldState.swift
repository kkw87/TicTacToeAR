//
//  WorldState.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 1/13/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import UIKit
import ARKit

class WorldState: NSObject, NSCoding {
    
    struct CodingKeys {
        static let CurrentGameState = "currentGameState"
        static let GameBoard = "gameBoard"
        static let WorldConfiguration = "worldConfiguration"
    }
    
    let currentGameState : CurrentGameData
    let gameBoard : TicTacToeBoard
    let currentWorldMap : ARWorldMap
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(currentGameState, forKey: CodingKeys.CurrentGameState)
        aCoder.encode(gameBoard, forKey : CodingKeys.GameBoard)
        aCoder.encode(currentWorldMap, forKey: CodingKeys.WorldConfiguration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        currentGameState = aDecoder.decodeObject(of: CurrentGameData.self, forKey: CodingKeys.CurrentGameState)!
        gameBoard = aDecoder.decodeObject(of: TicTacToeBoard.self, forKey: CodingKeys.GameBoard)!
        currentWorldMap = aDecoder.decodeObject(of: ARWorldMap.self, forKey: CodingKeys.WorldConfiguration)!
    }
    
    init(currentGameState : CurrentGameData, gameBoard : TicTacToeBoard, currentWorldConfiguration : ARWorldMap) {
        self.currentGameState = currentGameState
        self.gameBoard = gameBoard
        self.currentWorldMap = currentWorldConfiguration
    }
    
    
}

//    func networkSession(received worldTrackingConfiguration : ARWorldTrackingConfiguration, withGameBoard : TicTacToeBoard, withGameState : TicTacToeGameViewModel
