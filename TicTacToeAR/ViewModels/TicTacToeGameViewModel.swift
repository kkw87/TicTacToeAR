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
    func updateGameBoardWithPlayerMovement(withGamePiece : GamePiece)
    
}

enum GameState {
    case PlacingBoard
    case InProgress
    case GameOver
    case FindingBoardLocation
}

class TicTacToeGameViewModel {

    // MARK: - Constants
    struct StringLiterals {
        
        static let FindSurfaceMessage = "Find a flat surface to place the board"
        static let PlaceGridMessage = "Click on the grid to place the board"
        
        static let XPlayerTurnMessage = "X player's turn"
        static let OPlayerTurnMessage = "O player's turn"
        
        static let XPlayerVictoryMessage = "X Won!"
        static let OPlayerVictoryMessage = "O Won!"
        
        static let GameDrawTitleMessage = "It's a Draw!"
        static let GameDrawBodyMessage = "Would you like to reset the game?"
    }
    
    // MARK: - Tic Tac Toe Game
    private var ticTacToeGame : TicTacToe
    
    var boardPlaced = false {
        didSet {
            if boardPlaced {
                currentGameState = .InProgress
            } else {
                currentGameState = .FindingBoardLocation
            }
        }
    }
    
    var boardPlaneFound = false {
        didSet {
            if boardPlaneFound {
                currentGameState = .PlacingBoard
            }
        }
    }
    
    private(set) var currentGameState : GameState {
        didSet {
            switch currentGameState {
            case .FindingBoardLocation :
                delegate?.updateGameWith(statusText: StringLiterals.FindSurfaceMessage)
            case .InProgress :
                delegate?.clearPlacingNodesForGameStart()
                delegate?.updateGameWith(statusText: currentPlayer)
            case .PlacingBoard :
                delegate?.updateGameWith(statusText: StringLiterals.PlaceGridMessage)
            case .GameOver :
                
                if let gameOverMessage = gameEndingMessage {
                    
                    delegate?.presentGameEndingScreenWith(titleMessage: gameOverMessage.titleMessage, bodyMessage: gameOverMessage.bodyMessage, completion: { [unowned self] in
                        
                        self.delegate?.resetViewsForNewGame()
                        self.ticTacToeGame = TicTacToe()
                        self.boardPlaced = false
                        self.boardPlaneFound = false
                    })
                    
                }
            }
        }
    }
    
    // MARK: - Init
    init(ticTacToe : TicTacToe) {
        self.ticTacToeGame = ticTacToe
        self.currentGameState = .PlacingBoard
    }
    
    
    // MARK: - Instance Variables
    
    var delegate : TicTacToeGameViewModelDelegate?
    
    private var currentPlayer : String {
        switch ticTacToeGame.currentPlayerTurn {
        case .O :
            return StringLiterals.OPlayerTurnMessage
        default :
            return StringLiterals.XPlayerTurnMessage
            
        }
    }
    
    private var gameEndingMessage : (titleMessage : String, bodyMessage : String)? {
        guard ticTacToeGame.gameWon || ticTacToeGame.gameDraw else {
            return nil
        }
 
        if ticTacToeGame.gameWon {
            switch ticTacToeGame.currentPlayerTurn {
            case .X :
                return (StringLiterals.OPlayerVictoryMessage, StringLiterals.GameDrawBodyMessage)
            default :
                return (StringLiterals.XPlayerVictoryMessage, StringLiterals.GameDrawBodyMessage)
            }
        } else {
            return (StringLiterals.GameDrawTitleMessage, StringLiterals.GameDrawBodyMessage)
        }
    }
    
    // MARK: - Game move functions
    func playerMadeMove(atRow : Int, atColumn : Int) {
        
        guard ticTacToeGame.makeMove(atPosition: (atRow, atColumn)) else {
            return
        }
        
        delegate?.updateGameBoardWithPlayerMovement(withGamePiece: ticTacToeGame.currentPlayerTurn.oppositePiece)
        
        if let _ = gameEndingMessage {
            currentGameState = .GameOver
        } else {
            
            delegate?.updateGameWith(statusText: currentPlayer)
            
        }
    }
    
}
