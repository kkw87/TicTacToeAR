//
//  GameBoardState.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 2/11/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import Foundation

struct GameBoardState : Codable {
    let boardX : Float
    let boardY : Float
    let boardZ : Float
    
    let boardNodes : [GridNodeState]
}
