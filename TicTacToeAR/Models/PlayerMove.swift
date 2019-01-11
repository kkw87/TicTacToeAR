//
//  PlayerMove.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 1/5/19.
//  Copyright © 2019 Kevin Wang. All rights reserved.
//

import Foundation

class PlayerMove : NSObject, NSCoding {
    
    struct CodingKeys {
        static let RowKey = "row"
        static let ColumnKey = "column"
    }
    
    
    let playerMoveRow : Int
    let playerMoveColumn : Int
    
    
    init(row : Int, column : Int) {
        self.playerMoveRow = row
        self.playerMoveColumn = column
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(playerMoveRow, forKey: CodingKeys.RowKey)
        aCoder.encode(playerMoveColumn, forKey: CodingKeys.ColumnKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        playerMoveRow = aDecoder.decodeInteger(forKey: CodingKeys.RowKey)
        playerMoveColumn = aDecoder.decodeInteger(forKey: CodingKeys.ColumnKey)
    }
    
    override var description: String {
        return "Row : \(playerMoveRow), Column : \(playerMoveColumn)"
    }
    
}

extension PlayerMove : NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }
}
