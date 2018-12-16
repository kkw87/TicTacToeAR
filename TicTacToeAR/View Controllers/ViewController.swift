//
//  ViewController.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/6/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum GameState {
    case PlacingBoard
    case InProgress
    case GameOver
}

class ViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Constants
    struct StringLiterals {
        static let FindSurfaceMessage = "Find a flat surface to place the board"
        static let PlaceGridMessage = "Click on the grid to place the board"
    }
    
    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.layer.cornerRadius = 5
            statusLabel.layer.masksToBounds = true
        }
    }
    
    // MARK: - Model
    
    private var ticTacToeGame = TicTacToe()
    
    // MARK: - Instance variables

    private var gameBoard = TicTacToeBoard()
    
    private var currentAnchor : ARPlaneAnchor? {
        didSet {
            if oldValue != nil {
                sceneView.session.remove(anchor: oldValue!)
            }
        }
    }
    
    private var currentNode : SCNNode? {
        didSet {
            if currentNode != nil && currentAnchor != nil {
                currentNode!.addChildNode(PlacementGridNode(withAnchor: self.currentAnchor!))
            }
        }
    }
    
    private var currentGameState = GameState.PlacingBoard {
        didSet {
            switch currentGameState {
            case .InProgress:
                currentNode?.removeFromParentNode()
                ticTacToeGame = TicTacToe()
                statusText = currentPlayer
            case .GameOver :
                //Check if it is a draw or which player won
                //Clean up, remove all board pieces
                //Displaypopover to rset
                break
            case .PlacingBoard :
                statusText = StringLiterals.PlaceGridMessage
                currentNode = nil
                currentAnchor = nil
            }
        }
    }
    
    private var currentPlayer : String {
        get {
            switch ticTacToeGame.currentPlayerTurn {
            case .X :
                return "X's turn"
            default :
                return "O's turn"
            }
        }
    }
    
    private var statusText : String? {
        get {
            return statusLabel.text
        } set {
            statusLabel.text = newValue
        }
    }
    
    // MARK : - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTap(recognizer:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
       func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        switch currentGameState {
        case .PlacingBoard:
            currentAnchor = planeAnchor
            currentNode = node
        default:
            break
        }

    }
    
    // MARK: - User interaction
    @objc private func userTap(recognizer : UITapGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: sceneView)
        
        switch currentGameState {
            
        case .PlacingBoard :
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard currentAnchor != nil, let hitTestResult = hitTestResults.first else {
                break
            
            }
            setGameBoardAt(userPressedLocation: hitTestResult)
            
        case .InProgress :
            
            let hitTestResults = sceneView.hitTest(tapLocation, options: [SCNHitTestOption.firstFoundOnly: false, SCNHitTestOption.rootNode : gameBoard])
           userPressedMove(atLocation: hitTestResults)
            
            break
        default :
            break
        }

        
    }
    
    // MARK: - Game placement functions
    private func setGameBoardAt(userPressedLocation hitTestResult : ARHitTestResult) {
        
        gameBoard.position = SCNVector3Make(hitTestResult.worldTransform.columns.3.x, hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(gameBoard)
        let action = SCNAction.fadeIn(duration: 0.5)
        gameBoard.runAction(action)
        currentGameState = .InProgress
    }
    
    private func userPressedMove(atLocation hitTestResults: [SCNHitTestResult]) {
        
        guard let firstNode = hitTestResults.first, let clickedGridNode = firstNode.node as? GridNode, currentGameState == .InProgress else {
            return
        }
        
        if ticTacToeGame.makeMove(atPosition: (row: clickedGridNode.row, column: clickedGridNode.column)) {
            putPieceAt(node: clickedGridNode)
            updateGameState()
        }
        
    }
    
    private func putPieceAt(node : SCNNode) {
        let pieceToPlace = ticTacToeGame.currentPlayerTurn.oppositePiece
        let newNode = GamePieceNode(currentGamePiece: pieceToPlace)
        node.addChildNode(newNode)
    }
    

    // MARK: - Game status functions
    
    private func updateGameState() {
        
        
        if ticTacToeGame.gameDraw || ticTacToeGame.gameWon {
            currentGameState = .GameOver
        } else if currentGameState == .InProgress {
            statusText = currentPlayer
        }
        
        
    }
    
}
