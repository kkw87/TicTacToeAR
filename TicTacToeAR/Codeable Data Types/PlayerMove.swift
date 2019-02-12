//
//  PlayerMove.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 1/5/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct PlayerMove : Codable, CustomStringConvertible {
    
    let row : Int
    let column : Int

    var description: String {
        return "Row : \(row), Column : \(column)"
    }
    
}
