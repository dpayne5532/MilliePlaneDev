//
//  MenuScene.swift
//  MilliePlane
//
//  1980s arcade-style start screen
//

import SpriteKit

class MenuScene: SKScene {

    private var blinkAction: SKAction!
    private var highScoreNodes: [SKNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = .black

        setupTitle()
        setupHighScores()
        setupStartPrompt()
        setupCredits()
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

    private func setupStartPrompt() {
        let startLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        startLabel.text = "TAP ANYWHERE TO START"
        startLabel.fontSize = 28
        startLabel.fontColor = .white
        startLabel.position = CGPoint(x: 0, y: -120)
        startLabel.zPosition = 10
        startLabel.name = "startPrompt"
        addChild(startLabel)

        // Blinking animation
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.5)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        startLabel.run(SKAction.repeatForever(blink))
    }

    private func setupCredits() {
        let dedicationLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        dedicationLabel.text = "Mille Plane is dedicated to the best niece ever... Millie Payne"
        dedicationLabel.fontSize = 18
        dedicationLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.8, alpha: 1.0) // Pink
        dedicationLabel.position = CGPoint(x: 0, y: -280)
        dedicationLabel.zPosition = 10
        addChild(dedicationLabel)

        let creditsLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        creditsLabel.text = "© 2024 MILLIE PLANE"
        creditsLabel.fontSize = 16
        creditsLabel.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        creditsLabel.position = CGPoint(x: 0, y: -320)
        creditsLabel.zPosition = 10
        addChild(creditsLabel)
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
        startGame()
    }

    private func startGame() {
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            view?.presentScene(scene, transition: transition)
        }
    }
}
