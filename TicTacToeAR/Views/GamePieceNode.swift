//
//  GamePiece.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/15/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import SceneKit

class GamePieceNode : SCNNode  {
    
    // MARK: - Constants
    struct Constants {
        static let XPieceName = "art.scnassets/Patrick.scn"
        static let OPieceName = "art.scnassets/Spongebob.scn"
    }
    
    // MARK: - Init
    init(currentGamePiece : String) {
        super.init()
        
        let sceneName : String
        let modelScale : SCNVector3
        let modelPosition : SCNVector3
        switch currentGamePiece {
        case GamePiece.X:
            //Patrick model
            sceneName = Constants.XPieceName
            modelScale = SCNVector3(0.040, 0.040, 0.040)
            modelPosition = SCNVector3(0, GridNode.Constants.BoxHeight, 0)
        default:
            //Spongebob model
            sceneName = Constants.OPieceName
            modelScale = SCNVector3(0.015, 0.015, 0.015)
            modelPosition = SCNVector3(0, GridNode.Constants.BoxHeight, GridNode.Constants.BoxLength * 0.5)
        }
        
        let newScene = SCNScene(named: sceneName)!
        let gamePieceNode = newScene.rootNode.childNodes.first
        self.geometry = gamePieceNode?.geometry
        self.scale = modelScale
        self.eulerAngles.x = -.pi / 2
        self.position = modelPosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
