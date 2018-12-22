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

class TicTacToeViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.roundEdges()
        }
    }
    
    // MARK: - Model
    
    private lazy var ticTacToeViewModel : TicTacToeGameViewModel = {
       var tttVM = TicTacToeGameViewModel(ticTacToe: TicTacToe())
        tttVM.delegate = self
        return tttVM
    }()
    
    // MARK: - Instance variables

    //The gameboard in which pieces will be placed
    private var gameBoard = TicTacToeBoard()
    
    //The current anchor in which the user is currently facing , this will be reset everytime the camera angle changes
    private var currentAnchor : ARPlaneAnchor? {
        didSet {
            if oldValue != nil {
                sceneView.session.remove(anchor: oldValue!)
            }
        }
    }
    
    //The current node in which the board will be added.
    private var currentNode : SCNNode? {
        didSet {
            if currentNode != nil && currentAnchor != nil {
                currentNode!.addChildNode(PlacementGridNode(withAnchor: self.currentAnchor!))
                ticTacToeViewModel.boardPlaneFound = true
            }
        }
    }
    
    //Store the tapped node, we update this when we want to add a game piece(x or o)
    private var tappedNodeToAddGamePiece : GridNode?
    
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
        
        //If we detect a node or anchor, set it incase the user decides to place a gameboard node
        switch ticTacToeViewModel.currentGameState {
        case .FindingBoardLocation :
            fallthrough
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
        
        switch ticTacToeViewModel.currentGameState {
            
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
        ticTacToeViewModel.boardPlaced = true
    }
    
    private func userPressedMove(atLocation hitTestResults: [SCNHitTestResult]) {
        
        guard let firstNode = hitTestResults.first, let clickedGridNode = firstNode.node as? GridNode, ticTacToeViewModel.currentGameState == .InProgress else {
            return
        }
        
        tappedNodeToAddGamePiece = clickedGridNode
        ticTacToeViewModel.playerMadeMove(atRow: clickedGridNode.row, atColumn: clickedGridNode.column)

    }
  
}

extension TicTacToeViewController : TicTacToeGameViewModelDelegate {

    
    func presentGameEndingScreenWith(titleMessage: String, bodyMessage: String, completion: @escaping () -> Void) {
        
        let drawGameAlertVC = UIAlertController(title: titleMessage, message: bodyMessage, preferredStyle: .alert)
        drawGameAlertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: {[unowned self] (_) in
            let fadeOutAction = SCNAction.fadeOut(duration: 0.5)
            self.gameBoard.runAction(fadeOutAction, completionHandler: {
                completion()
            })
        }))
        drawGameAlertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(drawGameAlertVC, animated: true, completion: nil)
        
    }
    
    
    func updateGameWith(statusText: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusLabel.text = statusText
        }
    }

    
    func clearPlacingNodesForGameStart() {
        currentNode?.removeFromParentNode()
    }
    
    func resetViewsForNewGame() {
        currentAnchor = nil
        gameBoard.removeFromParentNode()
        gameBoard = TicTacToeBoard()
        currentNode = nil
        tappedNodeToAddGamePiece = nil
    }
    
    func updateGameBoardWithPlayerMovement(withGamePiece: GamePiece) {
        
        guard tappedNodeToAddGamePiece != nil else {
            return
        }
        
        let newGamePieceNode = GamePieceNode(currentGamePiece: withGamePiece)
        newGamePieceNode.opacity = 0
        let action = SCNAction.fadeIn(duration: 0.5)
        newGamePieceNode.runAction(action)
        
        tappedNodeToAddGamePiece!.addChildNode(newGamePieceNode)
        
    }

}
