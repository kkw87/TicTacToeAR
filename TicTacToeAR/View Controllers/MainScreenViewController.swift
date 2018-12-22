//
//  MainScreenViewController.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/22/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController {

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
    
    // MARK : - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
