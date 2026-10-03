//
//  MenuScene.swift
//  MilliePlane
//
//  1980s arcade-style start screen with game mode selection
//

import SpriteKit

class MenuScene: SKScene {

    private var blinkAction: SKAction!
    private var highScoreNodes: [SKNode] = []
    private var selectedMode: GameMode = .endless

    override func didMove(to view: SKView) {
        backgroundColor = .black

        setupTitle()
        setupHighScores()
        setupModeSelection()
        setupCredits()
        setupSettingsToggles()
        setupDecorations()
    }

    private func setupTitle() {
        // Main title with retro styling
        let titleLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        titleLabel.text = "MILLIE PLANE"
        titleLabel.fontSize = 72
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Arcade yellow
        titleLabel.position = CGPoint(x: 0, y: 280)
        titleLabel.zPosition = 10
        addChild(titleLabel)

        // Add glow effect to title
        let glowLabel = titleLabel.copy() as! SKLabelNode
        glowLabel.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.5)
        glowLabel.position = CGPoint(x: 2, y: 278)
        glowLabel.zPosition = 9
        addChild(glowLabel)

        // Subtitle
        let subtitleLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        subtitleLabel.text = "- COLLECT MILLIE BUCKS -"
        subtitleLabel.fontSize = 24
        subtitleLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0) // Cyan
        subtitleLabel.position = CGPoint(x: 0, y: 220)
        subtitleLabel.zPosition = 10
        addChild(subtitleLabel)
    }

    private func setupHighScores() {
        // High scores header
        let headerLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        headerLabel.text = "HIGH SCORES"
        headerLabel.fontSize = 36
        headerLabel.fontColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0) // Red
        headerLabel.position = CGPoint(x: 0, y: 150)
        headerLabel.zPosition = 10
        addChild(headerLabel)

        // Decorative line
        let lineNode = SKShapeNode(rectOf: CGSize(width: 400, height: 2))
        lineNode.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        lineNode.strokeColor = .clear
        lineNode.position = CGPoint(x: 0, y: 130)
        lineNode.zPosition = 10
        addChild(lineNode)

        let scores = HighScoreManager.shared.getHighScores()

        if scores.isEmpty {
            let noScoresLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
            noScoresLabel.text = "NO SCORES YET"
            noScoresLabel.fontSize = 20
            noScoresLabel.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            noScoresLabel.position = CGPoint(x: 0, y: 50)
            noScoresLabel.zPosition = 10
            addChild(noScoresLabel)
        } else {
            // Display top 5 scores on menu
            let displayCount = min(5, scores.count)
            for i in 0..<displayCount {
                let entry = scores[i]
                let yPos = 100 - (i * 35)

                // Rank
                let rankLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
                rankLabel.text = "\(i + 1)."
                rankLabel.fontSize = 22
                rankLabel.fontColor = rankColor(for: i + 1)
                rankLabel.horizontalAlignmentMode = .right
                rankLabel.position = CGPoint(x: -180, y: yPos)
                rankLabel.zPosition = 10
                addChild(rankLabel)

                // Name
                let nameLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
                nameLabel.text = String(entry.name.prefix(10))
                nameLabel.fontSize = 22
                nameLabel.fontColor = .white
                nameLabel.horizontalAlignmentMode = .left
                nameLabel.position = CGPoint(x: -150, y: yPos)
                nameLabel.zPosition = 10
                addChild(nameLabel)

                // Score
                let scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
                scoreLabel.text = "$\(entry.score).00"
                scoreLabel.fontSize = 22
                scoreLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0) // Green
                scoreLabel.horizontalAlignmentMode = .right
                scoreLabel.position = CGPoint(x: 180, y: yPos)
                scoreLabel.zPosition = 10
                addChild(scoreLabel)
            }
        }
    }

    private func rankColor(for rank: Int) -> SKColor {
        switch rank {
        case 1: return SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)  // Gold
        case 2: return SKColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) // Silver
        case 3: return SKColor(red: 0.80, green: 0.50, blue: 0.20, alpha: 1.0) // Bronze
        default: return SKColor.white
        }
    }

    private func setupModeSelection() {
        // Mode selection header
        let selectLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        selectLabel.text = "SELECT MODE"
        selectLabel.fontSize = 24
        selectLabel.fontColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        selectLabel.position = CGPoint(x: 0, y: -100)
        selectLabel.zPosition = 10
        addChild(selectLabel)

        // Endless Mode Button
        let endlessButton = createModeButton(
            mode: .endless,
            position: CGPoint(x: -150, y: -160),
            name: "endlessButton"
        )
        addChild(endlessButton)

        // Target Score Button
        let targetButton = createModeButton(
            mode: .targetScore,
            position: CGPoint(x: 150, y: -160),
            name: "targetButton"
        )
        addChild(targetButton)

        // Instructions
        let instructionLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        instructionLabel.text = "TAP A MODE TO START"
        instructionLabel.fontSize = 20
        instructionLabel.fontColor = .white
        instructionLabel.position = CGPoint(x: 0, y: -230)
        instructionLabel.zPosition = 10
        instructionLabel.name = "startPrompt"
        addChild(instructionLabel)

        // Blinking animation
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.5)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        instructionLabel.run(SKAction.repeatForever(blink))
    }

    private func createModeButton(mode: GameMode, position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = name

        // Button background
        let background = SKShapeNode(rectOf: CGSize(width: 200, height: 80), cornerRadius: 10)
        background.fillColor = mode == .endless ?
            SKColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0) :  // Blue for endless
            SKColor(red: 0.0, green: 0.6, blue: 0.3, alpha: 1.0)    // Green for target
        background.strokeColor = .white
        background.lineWidth = 3
        background.glowWidth = 2
        container.addChild(background)

        // Mode name
        let titleLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        titleLabel.text = mode.displayName
        titleLabel.fontSize = 18
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 10)
        titleLabel.verticalAlignmentMode = .center
        container.addChild(titleLabel)

        // Mode description
        let descLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        descLabel.text = mode.description
        descLabel.fontSize = 14
        descLabel.fontColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        descLabel.position = CGPoint(x: 0, y: -15)
        descLabel.verticalAlignmentMode = .center
        container.addChild(descLabel)

        // Pulsing animation
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.8)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        container.run(SKAction.repeatForever(pulse))

        return container
    }

    private func setupCredits() {
        let dedicationLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        dedicationLabel.text = "Millie Plane is dedicated to the best niece ever... Millie Payne"
        dedicationLabel.fontSize = 18
        dedicationLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.8, alpha: 1.0) // Pink
        dedicationLabel.position = CGPoint(x: 0, y: -268)
        dedicationLabel.zPosition = 10
        addChild(dedicationLabel)

        // In loving memory - gently glows in and out
        let grandmaLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        grandmaLabel.text = "For Grandma Karen"
        grandmaLabel.fontSize = 20
        grandmaLabel.fontColor = SKColor(red: 0.85, green: 0.75, blue: 1.0, alpha: 1.0) // Soft lavender
        grandmaLabel.position = CGPoint(x: 0, y: -298)
        grandmaLabel.zPosition = 10
        addChild(grandmaLabel)

        let glow = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 2.0),
            SKAction.fadeAlpha(to: 1.0, duration: 2.0)
        ])
        grandmaLabel.run(SKAction.repeatForever(glow))

        let creditsLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        creditsLabel.text = "© 2024 MILLIE PLANE"
        creditsLabel.fontSize = 16
        creditsLabel.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        creditsLabel.position = CGPoint(x: 0, y: -330)
        creditsLabel.zPosition = 10
        addChild(creditsLabel)
    }

    private func setupSettingsToggles() {
        addChild(createToggle(name: "musicToggle", position: CGPoint(x: -410, y: -325)))
        addChild(createToggle(name: "soundToggle", position: CGPoint(x: 410, y: -325)))
        updateToggleLabels()
    }

    private func createToggle(name: String, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = name
        container.position = position
        container.zPosition = 10

        let background = SKShapeNode(rectOf: CGSize(width: 150, height: 44), cornerRadius: 8)
        background.name = "background"
        background.lineWidth = 2
        container.addChild(background)

        let label = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        label.name = "label"
        label.zPosition = 1
        label.fontSize = 16
        label.verticalAlignmentMode = .center
        container.addChild(label)

        return container
    }

    private func updateToggleLabels() {
        let toggles = [
            ("musicToggle", "MUSIC", GameSettings.isMusicOn),
            ("soundToggle", "SOUND", GameSettings.isSoundOn)
        ]
        let onColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)  // Cyan
        let offColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

        for (name, title, isOn) in toggles {
            guard let toggle = childNode(withName: name) else { continue }
            let color = isOn ? onColor : offColor
            if let label = toggle.childNode(withName: "label") as? SKLabelNode {
                label.text = "\(title): \(isOn ? "ON" : "OFF")"
                label.fontColor = color
            }
            if let background = toggle.childNode(withName: "background") as? SKShapeNode {
                background.strokeColor = color
                background.fillColor = color.withAlphaComponent(0.15)
            }
        }
    }

    private func setupDecorations() {
        // Add some decorative stars/dots for that arcade feel
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            star.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: CGFloat.random(in: 0.3...0.8))
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: -500...500),
                y: CGFloat.random(in: -350...350)
            )
            star.zPosition = 1
            addChild(star)

            // Twinkle animation
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 0.5...1.5)),
                SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 0.5...1.5))
            ])
            star.run(SKAction.repeatForever(twinkle))
        }

        // Add the plane sprite as decoration
        let plane = SKSpriteNode(imageNamed: "logoPlane")
        plane.position = CGPoint(x: -350, y: 280)
        plane.zPosition = 10
        plane.setScale(0.8)
        addChild(plane)

        // Animate the plane
        let moveRight = SKAction.moveBy(x: 700, y: 0, duration: 4.0)
        let moveLeft = SKAction.moveBy(x: -700, y: 0, duration: 0)
        let wobble = SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 0.5),
            SKAction.rotate(byAngle: -0.2, duration: 1.0),
            SKAction.rotate(byAngle: 0.1, duration: 0.5)
        ])
        let moveAndWobble = SKAction.group([moveRight, SKAction.repeat(wobble, count: 2)])
        let flySequence = SKAction.sequence([moveAndWobble, moveLeft])
        plane.run(SKAction.repeatForever(flySequence))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        for node in nodes {
            if node.name == "endlessButton" || node.parent?.name == "endlessButton" {
                startGame(mode: .endless)
                return
            } else if node.name == "targetButton" || node.parent?.name == "targetButton" {
                startGame(mode: .targetScore)
                return
            } else if node.name == "musicToggle" || node.parent?.name == "musicToggle" {
                GameSettings.isMusicOn.toggle()
                updateToggleLabels()
                return
            } else if node.name == "soundToggle" || node.parent?.name == "soundToggle" {
                GameSettings.isSoundOn.toggle()
                updateToggleLabels()
                return
            }
        }
    }

    private func startGame(mode: GameMode) {
        let scene = GameScene(gameMode: mode)
        scene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }
}
