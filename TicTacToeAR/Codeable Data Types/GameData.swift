//
//  CurrentGameData.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 1/13/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import UIKit

struct GameData : Codable {
    let currentGameState : String
    let currentGame : TicTacToe
    let boardPlaced : Bool
    var boardPlaneFound : Bool
}
