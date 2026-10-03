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

        if let view = self.view as? SKView {
            view.preferredFramesPerSecond = 120
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Present the menu once the view has its real size, so the scene matches the screen's shape
        if let view = self.view as? SKView, view.scene == nil {
            SceneLayout.present(MenuScene(), in: view)
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
