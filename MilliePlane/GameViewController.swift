//
//  GameViewController.swift
//  MilliePlane
//
//  Hosts the SpriteKit view and launches the title screen
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Start with the menu scene
            let menuScene = MenuScene(size: CGSize(width: 1024, height: 768))
            menuScene.scaleMode = .aspectFill
            menuScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            view.presentScene(menuScene)

            view.preferredFramesPerSecond = 120
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
