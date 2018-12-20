//
//  Tests.swift
//  Tests
//
//  Created by Kevin Wang on 12/6/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import XCTest
@testable import TicTacToeAR

var ticTacToeGame = TicTacToe()

class Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPlayerMoves() {
        let validMoveInput = ticTacToeGame.makeMove(atPosition: (row: 10, column: 10))
        XCTAssertEqual(validMoveInput, true, "The row and column enterered are larger than the board.")
    }

}
