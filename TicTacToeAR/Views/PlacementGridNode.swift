//
//  PlacementGridNode.swift
//  TicTacToeAR
//
//  Created by Kevin Wang on 12/7/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class PlacementGridNode : SCNNode {
    
    // MARK: - Constants
    
    struct Constants {
        static let WidthHeightMultiplier = 50
    }
    
    struct ImageNames {
        static let GridMaterialAssetName = "art.scnassets/grid.png"
    }
    
    var preferredSize: CGSize = CGSize(width: 1.5, height: 2.7)
    
    var aspectRatio: Float { return Float(preferredSize.height / preferredSize.width) }
    
    init(withAnchor anchor : ARPlaneAnchor) {
        
        super.init()

        let placementGrid = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        self.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        self.eulerAngles.x = -.pi / 2
        
        
        
        let material = placementGrid.firstMaterial!
        material.diffuse.contents = UIImage(named: ImageNames.GridMaterialAssetName)
        
        self.geometry = placementGrid
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



