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
import MultipeerConnectivity

class TicTacToeViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Animation Constants
    struct Animation {
        static let MainViewFadeOutTime = 0.5
    }
    
    struct Storyboard {
        static let JoinGameSegue = "Join Segue"
    }
    
    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.roundEdges()
        }
    }
    @IBOutlet weak var mainScreenView: UIView! {
        didSet {
            mainScreenView.isOpaque = false
        }
    }
    
    
    // MARK: - Model
    
    private lazy var ticTacToeViewModel : TicTacToeGameViewModel = {
       var tttVM = TicTacToeGameViewModel(ticTacToe: TicTacToe())
        tttVM.delegate = self
        return tttVM
    }()
    
    var multipeerNetworkViewModel = MultipeerNetworkSessionViewModel(myself: UserDefaults.standard.myself, server: true)
    
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
    
    private var mainScreenIsHidden = false {
        didSet {
            if mainScreenIsHidden {
                
                UIView.animate(withDuration: Animation.MainViewFadeOutTime, animations: {
                    self.mainScreenView.alpha = 0
                }) { (_) in
                    self.mainScreenView.isHidden = true
                }
                
            } else {
                
                UIView.animate(withDuration: Animation.MainViewFadeOutTime, animations: {
                    self.mainScreenView.alpha = 1
                }) { (_) in
                    self.mainScreenView.isHidden = false
                }
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
    
    //MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTap(recognizer:))))
        multipeerNetworkViewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: - Reimplement word tracking check 
//
//        guard ARWorldTrackingConfiguration.isSupported else {
//            fatalError("ARKit is not available on this device.")
//        }
        
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
        
        // Start advertising multipeer availability
        if multipeerNetworkViewModel.isServer {
            multipeerNetworkViewModel.startAdvertising()
        }
        
    }
    
    private func userPressedMove(atLocation hitTestResults: [SCNHitTestResult]) {
        
        guard let firstNode = hitTestResults.first, let clickedGridNode = firstNode.node as? GridNode, ticTacToeViewModel.currentGameState == .InProgress else {
            return
        }
        
        
        
        tappedNodeToAddGamePiece = clickedGridNode
        
        let playerMove = PlayerMove(row: clickedGridNode.row, column: clickedGridNode.column)
        
        // Make sure it is your turn before a move is processed 
        guard multipeerNetworkViewModel.isMyTurn(currentPlayerTurn: ticTacToeViewModel.currentPlayer) else {
            return
        }
        
        ticTacToeViewModel.player(madeMove: playerMove)

        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: playerMove, requiringSecureCoding: true) else {
            return
        }
        
        multipeerNetworkViewModel.send(data: data)

    }
    
    // MARK: - Navigation
    @IBAction func unwindAsHost(segue: UIStoryboardSegue) {
        
        mainScreenIsHidden = true
        multipeerNetworkViewModel.isServer = true 
    }
    
    @IBAction func unwindAsPeer(segue: UIStoryboardSegue) {
        //User joined as a peer
        mainScreenIsHidden = true
        multipeerNetworkViewModel.isServer = false
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

extension TicTacToeViewController : MultipeerNetworkSessionViewModelDelegate {
    
    func networkSession(received gameState: TicTacToe) {
        ticTacToeViewModel.loadGameStateFrom(existingGame: gameState)
    }
    
    func networkSession(received command: PlayerMove) {
        //May need to make sure player isnt self
        ticTacToeViewModel.player(madeMove: command)
    }
    
    func networkSession(received worldTrackingConfiguration: ARWorldTrackingConfiguration) {
        
        if !multipeerNetworkViewModel.isServer {
            sceneView.session.run(worldTrackingConfiguration, options: [.resetTracking, .removeExistingAnchors])
        }
        
    }
    
    //Also send the currentGame state 
    
    func networkSession(joining player: Player) {
        
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            
            guard let map = worldMap else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else {
                fatalError("can't encode map")
            }
            
            self.multipeerNetworkViewModel.send(data: data)
        }
        
    }
    
    func networkSession(leaving player: Player) {
        //TODO: - Notification that player left 
    }
    
}
