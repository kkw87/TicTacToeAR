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
        
        for column in 0...2 {
            
            let lineOffset = boxWidth * 3 * 0.5 - (CGFloat(column + 1) * boxWidth - boxWidth * 0.5)
            
                for row in 0...2 {
                    
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
    
    func clearBoard() {
        for currentNode in gridSquares {
            currentNode.removeFromParentNode()
        }
    }
    
}
