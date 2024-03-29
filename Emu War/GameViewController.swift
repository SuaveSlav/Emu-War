//
//  GameViewController.swift
//  Emu War
//
//  Created by 90305539 on 10/5/18.
//  Copyright © 2018 Emir Sahbegovic. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true //hopefully this doesnt break everything
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
