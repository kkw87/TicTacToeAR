//
//  CurrentGameData.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 1/13/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import UIKit

//Structure used to save the current state of the game itself, as well as variables from the view model.
//The structure is used to send game data to a joining device 
struct GameData : Codable {
    let currentGameState : String
    let currentGame : TicTacToe
    let boardPlaced : Bool
    var boardPlaneFound : Bool
}
