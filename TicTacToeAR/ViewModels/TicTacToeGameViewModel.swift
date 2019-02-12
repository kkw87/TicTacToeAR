//
//  TicTacToeGameViewModel.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/18/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation

protocol TicTacToeGameViewModelDelegate {
    
    func updateGameWith(statusText : String)
    func presentGameEndingScreenWith(titleMessage : String, bodyMessage : String, completion : @escaping () -> Void)
    func clearPlacingNodesForGameStart()
    func resetViewsForNewGame()
}

class TicTacToeGameViewModel {

    // MARK: - Constants
    struct StringLiterals {
        
        static let XPlayerTurnMessage = "\(GamePiece.X)'s turn"
        static let OPlayerTurnMessage = "\(GamePiece.O)'s turn"
        
        static let XPlayerVictoryMessage = "\(GamePiece.X) Won!"
        static let OPlayerVictoryMessage = "\(GamePiece.O) Won!"
        
        static let GameDrawTitleMessage = "It's a Draw!"
        static let GameDrawBodyMessage = "Would you like to reset the game?"
    }
    
    // MARK: - Tic Tac Toe Game
    private var ticTacToeGame : TicTacToe
    
    var boardPlaced = false {
        didSet {
            if boardPlaced {
                currentGameState = BoardPlacementState.InProgress
            } else {
                currentGameState = BoardPlacementState.FindingBoardLocation
            }
        }
    }
    
    var boardPlaneFound = false {
        didSet {
            if boardPlaneFound {
                currentGameState = BoardPlacementState.PlacingBoard
            }
        }
    }
    
    private(set) var currentGameState : String {
        didSet {
            switch currentGameState {
            case BoardPlacementState.FindingBoardLocation :
                delegate?.updateGameWith(statusText: BoardPlacementState.FindingBoardLocation)
            case BoardPlacementState.InProgress :
                delegate?.clearPlacingNodesForGameStart()
                delegate?.updateGameWith(statusText: playerTurnMessage)
            case BoardPlacementState.PlacingBoard :
                delegate?.updateGameWith(statusText: BoardPlacementState.PlacingBoard)
            case BoardPlacementState.GameOver :
                
                if let gameOverMessage = gameEndingMessage {
                    
                    delegate?.presentGameEndingScreenWith(titleMessage: gameOverMessage.titleMessage, bodyMessage: gameOverMessage.bodyMessage, completion: { [unowned self] in
                        self.resetGame()
                    })
                    
                }
            default :
               currentGameState = BoardPlacementState.FindingBoardLocation
            }
        }
    }
    
    // MARK: - Init
    init(ticTacToe : TicTacToe) {
        self.ticTacToeGame = ticTacToe
        self.currentGameState = BoardPlacementState.PlacingBoard
    }
    
    
    // MARK: - Instance Variables
    
    var delegate : TicTacToeGameViewModelDelegate?
    
    var currentPlayer : String {
        return ticTacToeGame.currentPlayerTurn
    }
    
    var playerTurnMessage : String {
        
        switch ticTacToeGame.currentPlayerTurn {
        case GamePiece.O :
            return StringLiterals.OPlayerTurnMessage
        default :
            return StringLiterals.XPlayerTurnMessage
            
        } 
    }
    
    
    
    
    // MARK: - Game ending functions
    private var gameEndingMessage : (titleMessage : String, bodyMessage : String)? {
        guard ticTacToeGame.gameWon || ticTacToeGame.gameDraw else {
            return nil
        }
 
        if ticTacToeGame.gameWon {
            switch ticTacToeGame.currentPlayerTurn {
            case GamePiece.X :
                return (StringLiterals.OPlayerVictoryMessage, StringLiterals.GameDrawBodyMessage)
            default :
                return (StringLiterals.XPlayerVictoryMessage, StringLiterals.GameDrawBodyMessage)
            }
        } else {
            return (StringLiterals.GameDrawTitleMessage, StringLiterals.GameDrawBodyMessage)
        }
    }
    
    // MARK: - Game move functions
    func playerMadeMoveWith(move : PlayerMove) -> Bool {
        
        guard ticTacToeGame.makeMove(atPosition: (move.row, move.column)) else {
            return false
        }
        
        if let _ = gameEndingMessage {
            currentGameState = BoardPlacementState.GameOver
        } else {
            
            delegate?.updateGameWith(statusText: playerTurnMessage)
            
        }
        return true 
    }
    
    func resetGame() {
        delegate?.resetViewsForNewGame()
        ticTacToeGame = TicTacToe()
        boardPlaced = false
        boardPlaneFound = false
    }
    
    // MARK: - Game state functions
    
    func getGameState() -> GameData {
        let savedGameState = GameData(currentGameState : currentGameState, currentGame : ticTacToeGame, boardPlaced : boardPlaced, boardPlaneFound : boardPlaneFound)
        return savedGameState
    }
    
    func load(savedGameState : GameData) {

        ticTacToeGame = savedGameState.currentGame
        boardPlaced = savedGameState.boardPlaced
        boardPlaneFound = savedGameState.boardPlaneFound
        currentGameState = savedGameState.currentGameState
    }
    
}
