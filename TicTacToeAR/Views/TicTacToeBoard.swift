//
//  TicTacToeBoard.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/6/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import SceneKit
import ARKit


class TicTacToeBoard : SCNNode {
    
    // MARK: - Constants
    struct Constants {
        static let BoardRows = 3
        static let BoardHeight = 3
    }

    // MARK: - Instance Variables
    private(set) var gridSquares : [GridNode] = []
    
    // MARK: - Inits
    override init() {
        super.init()
        self.opacity = 0.0
        createBoard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Node creation convenience methods
    
    func createBoard() {

        let boxWidth = GridNode.Constants.BoxWidth
    
        for column in 0..<Constants.BoardHeight {
            
            let lineOffset = boxWidth * 3 * 0.5 - (CGFloat(column + 1) * boxWidth - boxWidth * 0.5)
            
                for row in 0..<Constants.BoardRows {
                    
                    let x = lineOffset + boxWidth * 0.5
                    let y : CGFloat = 0
                    let z = CGFloat(row - 1) * boxWidth
                    
                    let position = SCNVector3(x, y, z)
                    
                    let squareNode = GridNode(column: column, row: row)
                    squareNode.position = position
                    
                    self.addChildNode(squareNode)
                    gridSquares.append(squareNode)
                }
        }
    }
    
    // MARK: - Reset nodes
    func resetBoard() {
        let fadeOutAction = SCNAction.fadeOut(duration: 0.5)
        self.runAction(fadeOutAction) {
            for node in self.gridSquares {
                node.removeSymbolNode()
            }
        }
    }
    // MARK: - Update board
    func updateNodesWith(gridNodeStates : [GridNodeState]) {
        
        for newState in gridNodeStates {
            if let correspondingNode = gridSquares.first(where: { (gridNode) -> Bool in
                gridNode.row == newState.nodeRow && gridNode.column == newState.nodeColumn
            }) {
                correspondingNode.addToNode(gamePieceSymbol: newState.nodeSymbol)
            }
        }
    }
    
    private func currentGamePieceState() -> [GridNodeState] {
        return gridSquares.map {
            GridNodeState(nodeRow : $0.row, nodeColumn : $0.column, nodeSymbol : $0.nodeSymbol)
        }
    }

    
    // MARK: - Return grid nodes
    func nodeAtPosition(row: Int, column : Int) -> GridNode? {
        if row > Constants.BoardRows || row < 0 || column > Constants.BoardRows || column < 0 {
            return nil
        }
        
        let nodeToReturn = gridSquares.filter {
            $0.row == row && $0.column == column
        }
        
        return nodeToReturn.first
    }
    
    // MARK: - Board State
    func currentBoardState() -> GameBoardState {
        
        return GameBoardState(boardX : self.position.x, boardY : self.position.y, boardZ : self.position.y, boardNodes : currentGamePieceState())
    }
    
}
