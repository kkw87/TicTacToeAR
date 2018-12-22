//
//  TicTacToeARTests.swift
//  TicTacToeARTests
//
//  Created by Kevin Wang on 12/19/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import XCTest
@testable import TicTacToeAR

var ticTacToeGame : TicTacToe!

class TicTacToeARTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ticTacToeGame = TicTacToe()
    }
    
    override func tearDown() {
        ticTacToeGame = nil
        super.tearDown()

    }
    
    func testBoardLayout() {
        
        // Given
        let correctGameBoard = [[GamePiece.Empty, GamePiece.Empty, GamePiece.Empty],
                                [GamePiece.Empty, GamePiece.Empty, GamePiece.Empty],
                                [GamePiece.Empty, GamePiece.Empty, GamePiece.Empty]]
        
        // When
        let matchingGameBoards = correctGameBoard == ticTacToeGame.board
        
        
        // Then
        XCTAssertEqual(matchingGameBoards, true, "The current board is not initalized to a 3x3 grid of Empty nodes")
    }

    func testUserMoveInput() {
        
        // Given
        let invalidUserMoveInputNegative = (-1,-6)
        let invalidUserMoveInputLarge = (10,29)
        let validUserInput = (2,2)
        // When
        let firstTestResult = ticTacToeGame.makeMove(atPosition: invalidUserMoveInputNegative)
        let secondTestResult = ticTacToeGame.makeMove(atPosition: invalidUserMoveInputLarge)
        let thirdTestResult = ticTacToeGame.makeMove(atPosition: validUserInput)
        
        let fourthResult = ticTacToeGame.makeMove(atPosition: validUserInput)
        
        // Then
        XCTAssertEqual(firstTestResult, false, "The user entered an invalid move position that is smaller than 0 and it was accepted by the game.")
        XCTAssertEqual(secondTestResult, false, "The user entered an invalid move position that is larger than the board and it was accepted by the game.")
        XCTAssertEqual(thirdTestResult, true, "The user entered a valid move position and it was not accepted")
        XCTAssertEqual(fourthResult, false, "The user made an invalid move by placing a piece in a non empty box")

    }
    
    func testHorizontalRowWinConditions() {
        
        // Given
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (0,0))
        
        //YPlayer move
        _ = ticTacToeGame.makeMove(atPosition: (1,1))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (0,1))
        
        //Y Player move
        _ = ticTacToeGame.makeMove(atPosition: (1,2))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (0,2))
        
        // When
        
        let isGameWon = ticTacToeGame.gameWon
        
        // THen
        
        XCTAssertEqual(isGameWon, true, "The victory condition for placing all the pieces horizontally is not working.")
    }
    
    func testDiagnoalWinConditions() {
        
        //Given
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (0,0))
        
        //YPlayer move
        _ = ticTacToeGame.makeMove(atPosition: (0,1))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (1,1))
        
        //Y Player move
        _ = ticTacToeGame.makeMove(atPosition: (0,2))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (2,2))
        
        // When
        
        let isGameWon = ticTacToeGame.gameWon
        
        
        // Then
        XCTAssertEqual(isGameWon, true, "The victory condition for placing all the pieces diagnoally is not working.")
    }
    
    func testVerticalWinConditions() {
        
        //Given
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (0,0))
        
        //YPlayer move
        _ = ticTacToeGame.makeMove(atPosition: (0,1))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (1,0))
        
        //Y Player move
        _ = ticTacToeGame.makeMove(atPosition: (0,2))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (2,0))
        
        // When
        
        let isGameWon = ticTacToeGame.gameWon
        
        // Then
        XCTAssertEqual(isGameWon, true, "The victory condition for placing all the pieces vertically is not working.")
    }
    
    func testGameDrawCondition() {
        
        //Given
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (0,0))
        
        //YPlayer move
        _ = ticTacToeGame.makeMove(atPosition: (0,1))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (0,2))
        
        //Y Player move
        _ = ticTacToeGame.makeMove(atPosition: (1,1))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (1,0))
        
        //Y Player move
        _ = ticTacToeGame.makeMove(atPosition: (1,2))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (2,1))
        
        //Y Player move
        _ = ticTacToeGame.makeMove(atPosition: (2,0))
        
        //X Player move
        _ = ticTacToeGame.makeMove(atPosition: (2,2))
        
        //Game state
        
        //X  Y  X
        //X  Y  Y
        //Y  X  X
        
        // When
        let isGameADraw = ticTacToeGame.gameDraw
        
        // Then 

        XCTAssertEqual(isGameADraw, true, "The game does not properly detect a draw condition when the board is filled out.")
        
        
    }

}
