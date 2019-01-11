//
//  TicTacToe.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/6/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation


// MARK: - GamePiece Declaration
enum GamePiece : CustomStringConvertible {
    case X
    case O
    case Empty
    
    var oppositePiece : GamePiece {
        switch self {
        case .X:
            return .O
        case .O:
            return .X
        default:
            return .Empty
        }
    }
    
    var description: String {
        switch self {
        case .X :
            return "X"
        case .O :
            return "O"
        case .Empty :
            return "Empty"
        }
    }
}

class TicTacToe : NSObject, NSCoding {
    
    struct CodingKeys {
        static let BoardKey = "board"
        static let MoveRemaining = "key"
        static let CurrentTurn = "turn"
    }
    
    // MARK: - Game conditions
    private(set) var board : [[GamePiece]]
    
    private(set) var currentMovesRemaining : Int
    private(set) var currentPlayerTurn : GamePiece

    var gameWon : Bool {
        // Row 0 All Matching victory condition
        return board[0][0] == board[0][1] && board[0][1] == board[0][2] && board[0][0] != .Empty ||
        // Row 1 All Matching victory condition
        board[1][0] == board[1][1] && board[1][1] == board[1][2] && board[1][0] != .Empty ||
        // Row 2 All Matching victory condition
        board[2][0] == board[2][1] && board[2][1] == board[2][2] && board[2][0] != .Empty ||
        // Column 1 All Matching victory condition
        board[0][0] == board[1][0] && board[1][0] == board[2][0] && board[0][0] != .Empty ||
        // Column 2 All Matching victory condition
        board[0][1] == board[1][1] && board[1][1] == board[2][1] && board[0][1] != .Empty ||
        // Column 3 All Matching victory condition
        board[0][2] == board[1][2] && board[1][2] == board[2][2] && board[0][2] != .Empty ||
        // Diag 1 All Matching victory condition
        board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != .Empty ||
        // Diag 2 All Matching victory condition
        board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != .Empty
    }
    
    var gameDraw : Bool {
        return !gameWon && currentMovesRemaining == 0
    }
    
    // MARK: - Init
    init(boardPieces : [[GamePiece]] =
        [[GamePiece.Empty, GamePiece.Empty, GamePiece.Empty],
         [GamePiece.Empty, GamePiece.Empty, GamePiece.Empty],
         [GamePiece.Empty, GamePiece.Empty, GamePiece.Empty]],
         currentMovesRemaining : Int = 9,
         startingPlayer : GamePiece = .X) {
        
        self.board = boardPieces
        self.currentMovesRemaining = currentMovesRemaining
        self.currentPlayerTurn = startingPlayer
    }
    
    // MARK: - Game Moves
    
    func makeMove(atPosition position: (row : Int, column : Int)) -> Bool {
        
        guard position.row <= board.count && position.column <= board[0].count else {
            return false 
        }
        
        guard position.row >= 0 && position.column >= 0 else {
            return false
        }
        
        guard board[position.column][position.row] == .Empty else {
            return false
        }
        
        board[position.column][position.row] = currentPlayerTurn
        currentPlayerTurn = currentPlayerTurn.oppositePiece
        currentMovesRemaining -= 1
        
        return true
    }
    
    //MARK: - NSCoding Protocol
    func encode(with aCoder: NSCoder) {
        aCoder.encode(board, forKey: CodingKeys.BoardKey)
        aCoder.encode(currentMovesRemaining, forKey: CodingKeys.MoveRemaining)
        aCoder.encode(currentPlayerTurn, forKey: CodingKeys.CurrentTurn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        board = aDecoder.decodeObject(forKey: CodingKeys.BoardKey) as! [[GamePiece]]
        currentPlayerTurn = aDecoder.decodeObject(forKey: CodingKeys.CurrentTurn) as! GamePiece
        currentMovesRemaining = aDecoder.decodeInteger(forKey: CodingKeys.MoveRemaining)
    }
    
}

extension TicTacToe : NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    } 
}
