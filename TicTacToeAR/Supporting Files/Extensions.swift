//
//  Extensions.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/22/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addBlur(withBlurLevel blur: UIBlurEffect.Style = .light) {
        let blurEffect = UIBlurEffect(style: blur)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(blurView)
    }
    
    func roundEdges(withRadius : CGFloat = 5) {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
}
