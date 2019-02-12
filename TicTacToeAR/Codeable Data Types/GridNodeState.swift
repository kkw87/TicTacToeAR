//
//  GridNodeState.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 2/11/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import Foundation

struct GridNodeState : Codable {
    let nodeRow : Int
    let nodeColumn : Int
    let nodeSymbol : String 
}
