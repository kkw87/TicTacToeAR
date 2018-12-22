//
//  JoinGameViewController.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/22/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit

class JoinGameViewController: UIViewController {
    
    // MARK: - Storyboard
    struct Storyboard {
        static let JoinGameCellID = "Join Game Cell"
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
    
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Outlet functions
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension JoinGameViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "") as! UITableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
