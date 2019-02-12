//
//  JoinGameViewController.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/22/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class JoinGameViewController: UIViewController {
 
    // Needs a link to the network session
    
    // MARK: - Storyboard
    struct Storyboard {
        static let JoinGameCellID = "Join Game Cell"
        
        static let PeerSegue = "peerSegue"
    }

    // MARK: - Outlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.addBlur()   
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.roundEdges(withRadius: 10)
        }
    }
    
    private let myself = UserDefaults.standard.myself

    var networkSession : MultipeerNetworkSessionViewModel?
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkSession?.dataSource = self
        networkSession?.startBrowsing()
        
    }
    
    // MARK: - Outlet functions
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension JoinGameViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.JoinGameCellID)!
        
        if let currentGame = networkSession?.games[indexPath.row] {
            cell.textLabel?.text = currentGame.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkSession?.games.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let foundGame = networkSession?.games[indexPath.row] {
            networkSession?.join(game: foundGame)
            performSegue(withIdentifier: Storyboard.PeerSegue, sender: self)
        }
    }
}

extension JoinGameViewController : MultipeerNetworkSessionViewModelDataSource {
    func gamesUpdated() {
        tableView.reloadData()
    }
}
