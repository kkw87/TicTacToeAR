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
        static let FadeOutTimeDelay : TimeInterval = 3
    }
    
    struct Storyboard {
        static let JoinGameSegue = "Join Segue"
        static let PlayerJoinedLabelMessage = "Player Joined"
        static let PlayerLeftLabelMessage = "Player Left"
        static let HostResetMessage = "Waiting for host to reset the game"
    }
    
    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var playerJoinedLabel: UILabel! {
        didSet {
            playerJoinedLabel.roundEdges()
        }
    }
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.roundEdges()
        }
    }
    @IBOutlet weak var resetButton: UIButton! {
        didSet {
            resetButton.roundEdges()
        }
    }
    
    @IBOutlet weak var mainScreenView: UIView! {
        didSet {
            mainScreenView.isOpaque = false
        }
    }
    
    
    // MARK: - Model
    
    //View Model of the Tic Tac Toe Game
    private lazy var ticTacToeViewModel : TicTacToeGameViewModel = {
        var tttVM = TicTacToeGameViewModel(ticTacToe: TicTacToe())
        tttVM.delegate = self
        return tttVM
    }()
    
    var networkManager = MultipeerNetworkSessionViewModel(myself: UserDefaults.standard.myself, server: true)
    
    // MARK: - Instance variables
    
    //The gameboard in which pieces will be placed
    private var gameBoard = TicTacToeBoard()
    
    //The Encoder used to send player moves, game and world state to other devices
    private var networkJsonEncoder = JSONEncoder()
    
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
    
    private var playerStatusText = Storyboard.PlayerJoinedLabelMessage {
        didSet {
            DispatchQueue.main.async {
                
                self.playerJoinedLabel.text = self.playerStatusText
                
                UIView.animate(withDuration: Animation.MainViewFadeOutTime, delay: 0, options: .curveLinear, animations: {
                    self.playerJoinedLabel.alpha = 1
                }) { (completed) in
                    
                    UIView.animate(withDuration: Animation.MainViewFadeOutTime, delay: Animation.FadeOutTimeDelay, options: .curveLinear, animations: {
                        self.playerJoinedLabel.alpha = 0
                    }, completion: nil)
                    
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
    
    //MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTap(recognizer:))))
        networkManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
                guard ARWorldTrackingConfiguration.isSupported else {
                    fatalError("ARKit is not available on this device.")
                }
        
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
            
        case BoardPlacementState.FindingBoardLocation :
            fallthrough
        case BoardPlacementState.PlacingBoard:
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
            
        case BoardPlacementState.PlacingBoard :
            
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard currentAnchor != nil, let hitTestResult = hitTestResults.first else {
                break
                
            }
            
            networkManager.isMyTurn = true
            setGameBoardAt(userPressedLocation: hitTestResult)
            sendGameStateToPeers()
            
        case BoardPlacementState.InProgress :
            
            let hitTestResults = sceneView.hitTest(tapLocation, options: [SCNHitTestOption.firstFoundOnly: false, SCNHitTestOption.rootNode : gameBoard])
            userPressedNode(atLocation: hitTestResults)
            
            break
        default :
            break
        }
        
        
    }
    
    // MARK: - Game placement
    
    //Set game board using hit test results
    private func setGameBoardAt(userPressedLocation hitTestResult : ARHitTestResult) {
        
        let hitResultToVector = SCNVector3Make(hitTestResult.worldTransform.columns.3.x, hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)
        setGameBoardAt(location: hitResultToVector)
        
    }
    
    //Set game board with location from network data
    private func setGameBoardAt(location : SCNVector3) {
        
        gameBoard.position = location
        sceneView.scene.rootNode.addChildNode(gameBoard)
        let action = SCNAction.fadeIn(duration: 0.5)
        gameBoard.runAction(action)
        ticTacToeViewModel.boardPlaced = true
        
        // Start advertising multipeer availability
        if networkManager.isServer {
            networkManager.startAdvertising()
        }
    }
    
    private func userPressedNode(atLocation hitTestResults: [SCNHitTestResult]) {
        
        guard let firstNode = hitTestResults.first, let clickedGridNode = firstNode.node as? GridNode, ticTacToeViewModel.currentGameState == BoardPlacementState.InProgress else {
            return
        }
        
        let currentPlayerSymbol = ticTacToeViewModel.currentPlayer
        let playerMove = PlayerMove(row : clickedGridNode.row, column : clickedGridNode.column)
        
        guard networkManager.isMyTurn else {
            return
        }
        
        guard ticTacToeViewModel.playerMadeMoveWith(move: playerMove) else {
            return
        }
        
        networkManager.isMyTurn = networkManager.otherConnectedPlayers ? false : true
        clickedGridNode.addToNode(gamePieceSymbol: currentPlayerSymbol)
        
        do {
            let playerMoveData = try networkJsonEncoder.encode(playerMove)
            networkManager.send(data: playerMoveData)
            print("sending player move")
            
        } catch {
            print("Unable to encode player move!")
        }
        
        
    }
    
    // MARK: - Game reset
    
    @IBAction func exitCurrentGame(_ sender: Any) {
          let resetController = UIAlertController.gameResetAlertController { [unowned self] (_) in
                self.ticTacToeViewModel.resetGame()
                self.mainScreenIsHidden = false
                self.networkManager.leaveGame()
            }
            
            present(resetController, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    @IBAction func unwindAsHost(segue: UIStoryboardSegue) {
        
        mainScreenIsHidden = true
        networkManager.isServer = true 
    }
    
    @IBAction func unwindAsPeer(segue: UIStoryboardSegue) {
        //User joined as a peer
        mainScreenIsHidden = true
        networkManager.isServer = false
    }
    
}

// MARK: - TicTacToeGameViewModel Delegate

extension TicTacToeViewController : TicTacToeGameViewModelDelegate {
    
    func presentGameEndingScreenWith(titleMessage: String, bodyMessage: String, completion: @escaping () -> Void) {
        
        if networkManager.isServer {
            let drawGameAlertVC = UIAlertController(title: titleMessage, message: bodyMessage, preferredStyle: .alert)
            drawGameAlertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: {[unowned self] (_) in
                completion()
                self.gameBoard.resetBoard()
            }))
            drawGameAlertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            present(drawGameAlertVC, animated: true, completion: nil)
        } else {
            
            self.playerStatusText = titleMessage
            updateGameWith(statusText: Storyboard.HostResetMessage)
            self.gameBoard.resetBoard()
            
        }
        
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
    }
    
}

// MARK: - MultipeerNetworkSessionViewModel Delegate

extension TicTacToeViewController : MultipeerNetworkSessionViewModelDelegate {
    
    func networkSession(received gameBoardState: GameBoardState) {
        let x = gameBoardState.boardX
        let y = gameBoardState.boardY
        let z = gameBoardState.boardZ
        
        setGameBoardAt(location: SCNVector3Make(x, y, z))
        self.gameBoard.updateNodesWith(gridNodeStates: gameBoardState.boardNodes)
    }
    
    
    func networkSession(received command: PlayerMove) {
        
        let currentPlayerSymbol = ticTacToeViewModel.currentPlayer
        guard ticTacToeViewModel.playerMadeMoveWith(move: command) else {
            print("Invalid move from other player, ignoring...")
            return
        }
        
        if let nodeToUpdate = gameBoard.nodeAtPosition(row: command.row, column: command.column) {
            nodeToUpdate.addToNode(gamePieceSymbol: currentPlayerSymbol)
        } else {
            print("Unable to find node in response to a network player move")
        }
    }
    
    func networkSession(received gameState: GameData) {
        self.ticTacToeViewModel.load(savedGameState: gameState)
        networkManager.isMyTurn = self.ticTacToeViewModel.currentPlayer == networkManager.myGamePiece ? true : false
        
    }
    
    
    func networkSession(received worldTrackingConfiguration: ARWorldTrackingConfiguration) {
        
        if !networkManager.isServer {
            sceneView.session.run(worldTrackingConfiguration, options: [.resetTracking, .removeExistingAnchors])
            print("loaded world session ")
        }
        
    }
    
    //Also send the currentGame state 
    
    // MARK: - Player joining
    func networkSession(joining player: Player) {
        
        //If another player joins, check whether or not it is actually your turn, if they join when it is their tunr, you will be unable to make a move
        if networkManager.myGamePiece != ticTacToeViewModel.currentPlayer {
            networkManager.isMyTurn = false
        }
        
        if networkManager.isServer {
            playerStatusText = Storyboard.PlayerJoinedLabelMessage
        }
        
        sendGameStateToPeers()
        
    }
    
    func networkSession(leaving player: Player) {
        
        //When a player leaves, we want to
        networkManager.isMyTurn = true
        playerStatusText = Storyboard.PlayerLeftLabelMessage
        if self.networkManager.isServer {
            networkManager.startAdvertising()
        } else {
            self.networkManager.leaveGame()
            DispatchQueue.main.async {
                self.mainScreenIsHidden = false
            }
            self.ticTacToeViewModel.resetGame()
        }
    }
    
    func sendGameStateToPeers() {
        sceneView.session.getCurrentWorldMap { [unowned self] (worldMap, error) in
            
            guard self.networkManager.isServer else {
                return
            }
            
            guard let map = worldMap else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            let gameData = self.ticTacToeViewModel.getGameState()
            
            do {
                let worldMapData = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: false)
                print("Archived Data, attempting to send...")
                
                self.networkManager.send(data: worldMapData)
            } catch {
                print("Capture world error: \(error)")
            }
            
            do {
                let gameData = try self.networkJsonEncoder.encode(gameData)
                self.networkManager.send(data: gameData)
            } catch {
                print("Unable to encode game data")
            }
            
            let currentGameBoardState = self.gameBoard.currentBoardState()
            
            do {
                let boardStateData = try self.networkJsonEncoder.encode(currentGameBoardState)
                self.networkManager.send(data: boardStateData)
            } catch {
                print("Unable to encode game board state data")
            }
        }
    }
    
}

// MARK: - UIAlertController extensions

struct ResetAlertControllerMessages {
    static let ConfirmationButtonText = "Yes"
    static let DeclineButtonText = "No"
    
    static let PlayerLeftButtonText = "Continue"
    
    static let ResetTitleMessage = "Exit Game"
    static let ResetBodyMessage = "Are you sure you want to leave the current game?"
    
    static let PlayerLeftTitleMessage = "Player left"
    static let PlayerLeftBodyMessage = "The other player left the game!"
}

extension UIAlertController {
    
    static func gameResetAlertController(withHandler : @escaping (UIAlertAction)->Void) -> UIAlertController {
        let confirmationAction = UIAlertAction(title: ResetAlertControllerMessages.ConfirmationButtonText, style: .default, handler: withHandler)
        let declineAction = UIAlertAction(title: ResetAlertControllerMessages.DeclineButtonText, style: .cancel, handler: nil)
        
        let resetAlertController = UIAlertController(title: ResetAlertControllerMessages.ResetTitleMessage, message: ResetAlertControllerMessages.ResetBodyMessage, preferredStyle: .alert)
        resetAlertController.addAction(confirmationAction)
        resetAlertController.addAction(declineAction)
        
        return resetAlertController
    }
}
