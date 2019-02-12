//
//  TicTacToe.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/6/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation


class TicTacToe : NSObject, Codable {
    
    // MARK: - Game conditions
    private(set) var board : [[String]]
    
    private(set) var currentMovesRemaining : Int
    private(set) var currentPlayerTurn : String

    var gameWon : Bool {
        // Row 0 All Matching victory condition
        return board[0][0] == board[0][1] && board[0][1] == board[0][2] && board[0][0] != GamePiece.Empty ||
        // Row 1 All Matching victory condition
        board[1][0] == board[1][1] && board[1][1] == board[1][2] && board[1][0] != GamePiece.Empty ||
        // Row 2 All Matching victory condition
        board[2][0] == board[2][1] && board[2][1] == board[2][2] && board[2][0] != GamePiece.Empty ||
        // Column 1 All Matching victory condition
        board[0][0] == board[1][0] && board[1][0] == board[2][0] && board[0][0] != GamePiece.Empty ||
        // Column 2 All Matching victory condition
        board[0][1] == board[1][1] && board[1][1] == board[2][1] && board[0][1] != GamePiece.Empty ||
        // Column 3 All Matching victory condition
        board[0][2] == board[1][2] && board[1][2] == board[2][2] && board[0][2] != GamePiece.Empty ||
        // Diag 1 All Matching victory condition
        board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != GamePiece.Empty ||
        // Diag 2 All Matching victory condition
        board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != GamePiece.Empty
    }
    
    var gameDraw : Bool {
        return !gameWon && currentMovesRemaining == 0
    }
    
    // MARK: - Init
    init(boardPieces : [[String]] =
        [[GamePiece.Empty, GamePiece.Empty, GamePiece.Empty],
         [GamePiece.Empty, GamePiece.Empty, GamePiece.Empty],
         [GamePiece.Empty, GamePiece.Empty, GamePiece.Empty]],
         currentMovesRemaining : Int = 9,
         startingPlayer : String = GamePiece.X) {
        
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
        
        guard board[position.column][position.row] == GamePiece.Empty else {
            return false
        }
        
        board[position.column][position.row] = currentPlayerTurn
        currentPlayerTurn = currentPlayerTurn == GamePiece.X ? GamePiece.O : GamePiece.X
        currentMovesRemaining -= 1
        
        return true
    }
}
