//
//  MainScreenViewController.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/22/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController {
    
    // MARK: - Storyboard
    struct Storyboard {
        static let HostSegue = "Host Segue"
        static let JoinSegue = "Join Segue"
    }
    
    // MARK: - Instance Variables
    private let myself = UserDefaults.standard.myself

    // MARK: - Outlets 
    @IBOutlet weak var joinButton: UIButton! {
        didSet {
            joinButton.roundEdges()
        }
    }
    @IBOutlet weak var hostButton: UIButton! {
        didSet {
            hostButton.roundEdges()
        }
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        switch segueID {
        case Storyboard.JoinSegue:
            guard let parentVC = parent as? TicTacToeViewController, let destinationVC = segue.destination as? JoinGameViewController else {
                break
            }
            destinationVC.networkSession = parentVC.multipeerNetworkViewModel
            
        default:
            break
        }
    }
}
