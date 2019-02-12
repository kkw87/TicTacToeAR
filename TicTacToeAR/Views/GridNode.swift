//
//  GridNode.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/7/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import ARKit

class GridNode : SCNNode {
    
    // MARK: - Constants
    struct Constants {
        // Node creation measurements
        static let BoxWidth : CGFloat = 0.25
        static let BoxHeight : CGFloat = 0.07
        static let BoxLength : CGFloat = 0.25
        static let BoxChamfer : CGFloat = 0.01
        
        static let GamePieceFadeInTime : TimeInterval = 0.5
    }
    
    
    // MARK: - Assets
    struct ImageNames {
        static let BoxMaterialName = "art.scnassets/grass.png"
    }
    
    let row : Int
    let column : Int
    
    private(set) var nodeSymbol = GamePiece.Empty
    private var symbolNode : GamePieceNode?
    
    init(column : Int, row : Int) {
        self.row = row
        self.column = column
        
        super.init()
        
        let square = SCNBox(width: Constants.BoxWidth, height: Constants.BoxHeight, length: Constants.BoxLength, chamferRadius: Constants.BoxLength)
        square.firstMaterial?.diffuse.contents = UIImage(named: ImageNames.BoxMaterialName)
        self.geometry = square
        
        
    }
    
    func addToNode(gamePieceSymbol : String) {

        symbolNode?.removeFromParentNode()
        
        //Make sure the node is a game piece 
        if gamePieceSymbol == GamePiece.O || gamePieceSymbol == GamePiece.X {
            let newGamePieceNode = GamePieceNode(currentGamePiece: gamePieceSymbol)
            newGamePieceNode.opacity = 0
            let action = SCNAction.fadeIn(duration: Constants.GamePieceFadeInTime)
            newGamePieceNode.runAction(action)
            self.addChildNode(newGamePieceNode)
            nodeSymbol = gamePieceSymbol
            symbolNode = newGamePieceNode
        }
    }
    
    func removeSymbolNode() {
        symbolNode?.removeFromParentNode()
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
