//
//  GridNodeState.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 2/11/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import Foundation

//A structure used to gather the information of a grid node (a patch of grass that will contain the symbol on it) to send to the other device through MPC
struct GridNodeState : Codable {
    let nodeRow : Int
    let nodeColumn : Int
    let nodeSymbol : String 
}
