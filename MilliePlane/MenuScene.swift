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
    private var layout = Layout.regular

    /// Positions and sizes for each element. iPad uses the original layout;
    /// landscape iPhones get a two-column layout (scores left, modes right).
    private struct Layout {
        var titleY: CGFloat = 280, titleFontSize: CGFloat = 72
        var subtitleY: CGFloat = 220, subtitleFontSize: CGFloat = 24
        var planeY: CGFloat = 280, planeScale: CGFloat = 0.8

        var scoresHeaderY: CGFloat = 150, scoresHeaderFontSize: CGFloat = 36
        var scoresLineY: CGFloat = 130, scoresLineWidth: CGFloat = 400
        var scoresFirstRowY: CGFloat = 100, scoresRowSpacing: CGFloat = 35, scoresFontSize: CGFloat = 22
        var scoresCenterX: CGFloat = 0, rankX: CGFloat = -180, nameX: CGFloat = -150, scoreX: CGFloat = 180
        var noScoresY: CGFloat = 50

        var modesCenterX: CGFloat = 0
        var selectModeY: CGFloat = -100, selectModeFontSize: CGFloat = 24
        var endlessButtonPosition = CGPoint(x: -150, y: -160)
        var targetButtonPosition = CGPoint(x: 150, y: -160)
        var buttonSize = CGSize(width: 200, height: 80)
        var tapPromptY: CGFloat = -230, tapPromptFontSize: CGFloat = 20

        var dedicationY: CGFloat = -268, dedicationFontSize: CGFloat = 18
        var grandmaY: CGFloat = -298, grandmaFontSize: CGFloat = 20
        var creditsY: CGFloat = -330, creditsFontSize: CGFloat = 16

        var musicTogglePosition = CGPoint(x: -410, y: -325)
        var soundTogglePosition = CGPoint(x: 410, y: -325)
        var toggleSize = CGSize(width: 150, height: 44), toggleFontSize: CGFloat = 16

        static let regular = Layout()

        static func compact(sceneSize: CGSize, safeFrame safe: CGRect) -> Layout {
            var layout = Layout()
            let top = sceneSize.height / 2

            layout.titleY = top - 58
            layout.titleFontSize = 52
            layout.subtitleY = top - 88
            layout.subtitleFontSize = 18
            layout.planeY = layout.titleY
            layout.planeScale = 0.55

            // The columns are laid out for a ~474pt-tall screen; on taller phones
            // (e.g. iPhone SE) shift them down to stay centered between title and dedication
            let columnsTop = top - max(0, sceneSize.height - 474) / 2

            // Left column: high scores
            let scoresX: CGFloat = -250
            layout.scoresCenterX = scoresX
            layout.scoresHeaderY = columnsTop - 145
            layout.scoresHeaderFontSize = 26
            layout.scoresLineY = columnsTop - 160
            layout.scoresLineWidth = 320
            layout.scoresFirstRowY = columnsTop - 190
            layout.scoresRowSpacing = 28
            layout.scoresFontSize = 18
            layout.rankX = scoresX - 120
            layout.nameX = scoresX - 95
            layout.scoreX = scoresX + 140
            layout.noScoresY = columnsTop - 230

            // Right column: mode buttons stacked
            let modesX: CGFloat = 250
            layout.modesCenterX = modesX
            layout.selectModeY = columnsTop - 140
            layout.selectModeFontSize = 20
            layout.endlessButtonPosition = CGPoint(x: modesX, y: columnsTop - 195)
            layout.targetButtonPosition = CGPoint(x: modesX, y: columnsTop - 280)
            layout.buttonSize = CGSize(width: 220, height: 70)
            layout.tapPromptY = columnsTop - 340
            layout.tapPromptFontSize = 18

            // Bottom: dedication, clear of the home indicator
            layout.dedicationY = safe.minY + 56
            layout.dedicationFontSize = 16
            layout.grandmaY = safe.minY + 30
            layout.grandmaFontSize = 18
            layout.creditsY = safe.minY + 6
            layout.creditsFontSize = 13

            // Toggles in the bottom corners, clear of the Dynamic Island
            layout.musicTogglePosition = CGPoint(x: safe.minX + 75, y: safe.minY + 24)
            layout.soundTogglePosition = CGPoint(x: safe.maxX - 75, y: safe.minY + 24)
            layout.toggleSize = CGSize(width: 130, height: 36)
            layout.toggleFontSize = 14

            return layout
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black

        if SceneLayout.isCompact(self) {
            layout = Layout.compact(sceneSize: size, safeFrame: SceneLayout.safeFrame(of: self))
        }

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
        titleLabel.fontSize = layout.titleFontSize
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Arcade yellow
        titleLabel.position = CGPoint(x: 0, y: layout.titleY)
        titleLabel.zPosition = 10
        addChild(titleLabel)

        // Add glow effect to title
        let glowLabel = titleLabel.copy() as! SKLabelNode
        glowLabel.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.5)
        glowLabel.position = CGPoint(x: 2, y: layout.titleY - 2)
        glowLabel.zPosition = 9
        addChild(glowLabel)

        // Subtitle
        let subtitleLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        subtitleLabel.text = "- COLLECT MILLIE BUCKS -"
        subtitleLabel.fontSize = layout.subtitleFontSize
        subtitleLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0) // Cyan
        subtitleLabel.position = CGPoint(x: 0, y: layout.subtitleY)
        subtitleLabel.zPosition = 10
        addChild(subtitleLabel)
    }

    private func setupHighScores() {
        // High scores header
        let headerLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        headerLabel.text = "HIGH SCORES"
        headerLabel.fontSize = layout.scoresHeaderFontSize
        headerLabel.fontColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0) // Red
        headerLabel.position = CGPoint(x: layout.scoresCenterX, y: layout.scoresHeaderY)
        headerLabel.zPosition = 10
        addChild(headerLabel)

        // Decorative line
        let lineNode = SKShapeNode(rectOf: CGSize(width: layout.scoresLineWidth, height: 2))
        lineNode.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        lineNode.strokeColor = .clear
        lineNode.position = CGPoint(x: layout.scoresCenterX, y: layout.scoresLineY)
        lineNode.zPosition = 10
        addChild(lineNode)

        let scores = HighScoreManager.shared.getHighScores()

        if scores.isEmpty {
            let noScoresLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
            noScoresLabel.text = "NO SCORES YET"
            noScoresLabel.fontSize = 20
            noScoresLabel.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            noScoresLabel.position = CGPoint(x: layout.scoresCenterX, y: layout.noScoresY)
            noScoresLabel.zPosition = 10
            addChild(noScoresLabel)
        } else {
            // Display top 5 scores on menu
            let displayCount = min(5, scores.count)
            for i in 0..<displayCount {
                let entry = scores[i]
                let yPos = layout.scoresFirstRowY - CGFloat(i) * layout.scoresRowSpacing

                // Rank
                let rankLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
                rankLabel.text = "\(i + 1)."
                rankLabel.fontSize = layout.scoresFontSize
                rankLabel.fontColor = rankColor(for: i + 1)
                rankLabel.horizontalAlignmentMode = .right
                rankLabel.position = CGPoint(x: layout.rankX, y: yPos)
                rankLabel.zPosition = 10
                addChild(rankLabel)

                // Name
                let nameLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
                nameLabel.text = String(entry.name.prefix(10))
                nameLabel.fontSize = layout.scoresFontSize
                nameLabel.fontColor = .white
                nameLabel.horizontalAlignmentMode = .left
                nameLabel.position = CGPoint(x: layout.nameX, y: yPos)
                nameLabel.zPosition = 10
                addChild(nameLabel)

                // Score
                let scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
                scoreLabel.text = "$\(entry.score).00"
                scoreLabel.fontSize = layout.scoresFontSize
                scoreLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0) // Green
                scoreLabel.horizontalAlignmentMode = .right
                scoreLabel.position = CGPoint(x: layout.scoreX, y: yPos)
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
        selectLabel.fontSize = layout.selectModeFontSize
        selectLabel.fontColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        selectLabel.position = CGPoint(x: layout.modesCenterX, y: layout.selectModeY)
        selectLabel.zPosition = 10
        addChild(selectLabel)

        // Endless Mode Button
        let endlessButton = createModeButton(
            mode: .endless,
            position: layout.endlessButtonPosition,
            name: "endlessButton"
        )
        addChild(endlessButton)

        // Target Score Button
        let targetButton = createModeButton(
            mode: .targetScore,
            position: layout.targetButtonPosition,
            name: "targetButton"
        )
        addChild(targetButton)

        // Instructions
        let instructionLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        instructionLabel.text = "TAP A MODE TO START"
        instructionLabel.fontSize = layout.tapPromptFontSize
        instructionLabel.fontColor = .white
        instructionLabel.position = CGPoint(x: layout.modesCenterX, y: layout.tapPromptY)
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
        let background = SKShapeNode(rectOf: layout.buttonSize, cornerRadius: 10)
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
        dedicationLabel.fontSize = layout.dedicationFontSize
        dedicationLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.8, alpha: 1.0) // Pink
        dedicationLabel.position = CGPoint(x: 0, y: layout.dedicationY)
        dedicationLabel.zPosition = 10
        addChild(dedicationLabel)

        // In loving memory - gently glows in and out
        let grandmaLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        grandmaLabel.text = "For Grandma Karen"
        grandmaLabel.fontSize = layout.grandmaFontSize
        grandmaLabel.fontColor = SKColor(red: 0.85, green: 0.75, blue: 1.0, alpha: 1.0) // Soft lavender
        grandmaLabel.position = CGPoint(x: 0, y: layout.grandmaY)
        grandmaLabel.zPosition = 10
        addChild(grandmaLabel)

        let glow = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 2.0),
            SKAction.fadeAlpha(to: 1.0, duration: 2.0)
        ])
        grandmaLabel.run(SKAction.repeatForever(glow))

        let creditsLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        creditsLabel.text = "© 2024 MILLIE PLANE"
        creditsLabel.fontSize = layout.creditsFontSize
        creditsLabel.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        creditsLabel.position = CGPoint(x: 0, y: layout.creditsY)
        creditsLabel.zPosition = 10
        addChild(creditsLabel)
    }

    private func setupSettingsToggles() {
        addChild(createToggle(name: "musicToggle", position: layout.musicTogglePosition))
        addChild(createToggle(name: "soundToggle", position: layout.soundTogglePosition))
        updateToggleLabels()
    }

    private func createToggle(name: String, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = name
        container.position = position
        container.zPosition = 10

        let background = SKShapeNode(rectOf: layout.toggleSize, cornerRadius: 8)
        background.name = "background"
        background.lineWidth = 2
        container.addChild(background)

        let label = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        label.name = "label"
        label.zPosition = 1
        label.fontSize = layout.toggleFontSize
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
                x: CGFloat.random(in: -size.width / 2...size.width / 2),
                y: CGFloat.random(in: -size.height / 2...size.height / 2)
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
        plane.position = CGPoint(x: -350, y: layout.planeY)
        plane.zPosition = 10
        plane.setScale(layout.planeScale)
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
        guard let view = view else { return }
        SceneLayout.present(GameScene(gameMode: mode), in: view, transition: SKTransition.fade(withDuration: 0.5))
    }
}
