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

enum GameState : String, Codable {
    case PlacingBoard = "Click on the grid to place the board"
    case InProgress = "Game in progress"
    case GameOver = "Would you like to reset the game?"
    case FindingBoardLocation = "Find a flat surface to place the board"
}

class TicTacToeGameViewModel {

    // MARK: - Constants
    struct StringLiterals {
        
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
                delegate?.updateGameWith(statusText: currentGameState.rawValue)
            case .InProgress :
                delegate?.clearPlacingNodesForGameStart()
                delegate?.updateGameWith(statusText: currentGameState.rawValue)
            case .PlacingBoard :
                delegate?.updateGameWith(statusText: currentGameState.rawValue)
            case .GameOver :
                
                if let gameOverMessage = gameEndingMessage {
                    
                    delegate?.presentGameEndingScreenWith(titleMessage: gameOverMessage.titleMessage, bodyMessage: gameOverMessage.bodyMessage, completion: { [unowned self] in
                        
                        self.resetGame()
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
    
    var currentPlayer : GamePiece {
        return ticTacToeGame.currentPlayerTurn
    }
    
    var playerTurnMessage : String {
        
        switch ticTacToeGame.currentPlayerTurn {
        case .O :
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
    func player(madeMove : PlayerMove) {
        
        guard ticTacToeGame.makeMove(atPosition: (madeMove.playerMoveRow, madeMove.playerMoveColumn)) else {
            return
        }
        
        delegate?.updateGameBoardWithPlayerMovement(withGamePiece: ticTacToeGame.currentPlayerTurn.oppositePiece)
        
        if let _ = gameEndingMessage {
            currentGameState = .GameOver
        } else {
            
            delegate?.updateGameWith(statusText: playerTurnMessage)
            
        }
    }
    
    func resetGame() {
        delegate?.resetViewsForNewGame()
        ticTacToeGame = TicTacToe()
        boardPlaced = false
        boardPlaneFound = false
    }
    
    // MARK: - Game state functions
    func loadGameStateFrom(existingGame : TicTacToe) {
        ticTacToeGame = existingGame
    }
    
    func getGameState() -> CurrentGameData {
        let savedGameState = CurrentGameData(gameState: currentGameState, gameModel: ticTacToeGame, boardPlaced: boardPlaced, planeFound: boardPlaneFound)
        return savedGameState
    }
    
    func load(savedGameState : CurrentGameData) {
        ticTacToeGame = savedGameState.currentGame
        currentGameState = savedGameState.gameState
        boardPlaced = savedGameState.boardPlaced
        boardPlaneFound = savedGameState.boardPlaneFound
    }
    
}
