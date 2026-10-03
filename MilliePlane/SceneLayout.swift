//
//  SceneLayout.swift
//  MilliePlane
//
//  Sizes scenes to the device so nothing is cropped on iPhone or iPad.
//  Every scene is 1024 points wide; its height follows the screen's shape
//  (768 on a 4:3 iPad, ~474 on a landscape iPhone).
//

import SpriteKit

enum SceneLayout {
    static let width: CGFloat = 1024
    static let maxHeight: CGFloat = 768

    /// Scenes shorter than this (landscape iPhones) use the compact layout
    static let compactHeightThreshold: CGFloat = 600

    static func sceneSize(for view: SKView) -> CGSize {
        let bounds = view.bounds.size
        guard bounds.width > 0, bounds.height > 0 else {
            return CGSize(width: width, height: maxHeight)
        }
        let aspect = max(bounds.width, bounds.height) / min(bounds.width, bounds.height)
        return CGSize(width: width, height: min(maxHeight, (width / aspect).rounded()))
    }

    static func present(_ scene: SKScene, in view: SKView, transition: SKTransition? = nil) {
        scene.size = sceneSize(for: view)
        scene.scaleMode = .aspectFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        if let transition = transition {
            view.presentScene(scene, transition: transition)
        } else {
            view.presentScene(scene)
        }
    }

    static func isCompact(_ scene: SKScene) -> Bool {
        return scene.size.height < compactHeightThreshold
    }

    /// The part of the scene clear of the Dynamic Island, notch and home indicator,
    /// in scene coordinates (anchor point at the center)
    static func safeFrame(of scene: SKScene) -> CGRect {
        let w = scene.size.width
        let h = scene.size.height
        var frame = CGRect(x: -w / 2, y: -h / 2, width: w, height: h)

        guard let view = scene.view, view.bounds.width > 0 else { return frame }

        let pointsPerUnit = view.bounds.width / w
        let insets = view.safeAreaInsets
        frame.origin.x += insets.left / pointsPerUnit
        frame.origin.y += insets.bottom / pointsPerUnit
        frame.size.width -= (insets.left + insets.right) / pointsPerUnit
        frame.size.height -= (insets.top + insets.bottom) / pointsPerUnit
        return frame
    }
}
