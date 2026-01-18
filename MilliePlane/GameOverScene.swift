//
//  GameOverScene.swift
//  MilliePlane
//
//  1980s arcade-style game over screen with high score entry
//

import SpriteKit

class GameOverScene: SKScene {

    private let finalScore: Int
    private var nameEntry: String = ""
    private var nameLabel: SKLabelNode?
    private var cursorNode: SKShapeNode?
    private var isEnteringName = false
    private let maxNameLength = 10
    private var hasSubmittedScore = false

    // Character selection for name entry (arcade style)
    private let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    private var currentCharIndex = 0
    private var characterLabels: [SKLabelNode] = []

    init(score: Int) {
        self.finalScore = score
        super.init(size: CGSize(width: 1024, height: 768))
    }

    required init?(coder aDecoder: NSCoder) {
        self.finalScore = 0
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        setupGameOver()
        setupScoreDisplay()

        if HighScoreManager.shared.isHighScore(finalScore) {
            isEnteringName = true
            setupNameEntry()
        } else {
            setupHighScoresDisplay()
            setupContinuePrompt()
        }
    }

    private func setupGameOver() {
        let gameOverLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 64
        gameOverLabel.fontColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        gameOverLabel.position = CGPoint(x: 0, y: 280)
        gameOverLabel.zPosition = 10
        addChild(gameOverLabel)

        // Pulsing animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        gameOverLabel.run(SKAction.repeatForever(pulse))
    }

    private func setupScoreDisplay() {
        let yourScoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        yourScoreLabel.text = "YOUR SCORE"
        yourScoreLabel.fontSize = 24
        yourScoreLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        yourScoreLabel.position = CGPoint(x: 0, y: 210)
        yourScoreLabel.zPosition = 10
        addChild(yourScoreLabel)

        let scoreValueLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        scoreValueLabel.text = "$\(finalScore).00"
        scoreValueLabel.fontSize = 48
        scoreValueLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        scoreValueLabel.position = CGPoint(x: 0, y: 160)
        scoreValueLabel.zPosition = 10
        addChild(scoreValueLabel)

        if HighScoreManager.shared.isHighScore(finalScore) {
            let newHighLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
            newHighLabel.text = "NEW HIGH SCORE!"
            newHighLabel.fontSize = 28
            newHighLabel.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            newHighLabel.position = CGPoint(x: 0, y: 110)
            newHighLabel.zPosition = 10
            addChild(newHighLabel)

            // Flash animation
            let flash = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.3),
                SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            ])
            newHighLabel.run(SKAction.repeatForever(flash))
        }
    }

    private func setupNameEntry() {
        let enterNameLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        enterNameLabel.text = "ENTER YOUR NAME"
        enterNameLabel.fontSize = 24
        enterNameLabel.fontColor = .white
        enterNameLabel.position = CGPoint(x: 0, y: 50)
        enterNameLabel.zPosition = 10
        addChild(enterNameLabel)

        // Name display with underscores
        nameLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        nameLabel?.text = "___________"
        nameLabel?.fontSize = 36
        nameLabel?.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        nameLabel?.position = CGPoint(x: 0, y: 0)
        nameLabel?.zPosition = 10
        addChild(nameLabel!)

        // Character selector
        setupCharacterSelector()

        // Instructions
        let instructionLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        instructionLabel.text = "TAP LEFT/RIGHT TO SELECT  -  TAP CENTER TO ADD"
        instructionLabel.fontSize = 18
        instructionLabel.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        instructionLabel.position = CGPoint(x: 0, y: -150)
        instructionLabel.zPosition = 10
        addChild(instructionLabel)

        let doneLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        doneLabel.text = "TAP HERE WHEN DONE"
        doneLabel.fontSize = 22
        doneLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        doneLabel.position = CGPoint(x: 0, y: -200)
        doneLabel.zPosition = 10
        doneLabel.name = "doneButton"
        addChild(doneLabel)

        // Blink done button
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        doneLabel.run(SKAction.repeatForever(blink))

        // Backspace button
        let backspaceLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        backspaceLabel.text = "[DEL]"
        backspaceLabel.fontSize = 24
        backspaceLabel.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        backspaceLabel.position = CGPoint(x: 200, y: -60)
        backspaceLabel.zPosition = 10
        backspaceLabel.name = "backspace"
        addChild(backspaceLabel)
    }

    private func setupCharacterSelector() {
        // Left arrow
        let leftArrow = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        leftArrow.text = "<"
        leftArrow.fontSize = 48
        leftArrow.fontColor = .white
        leftArrow.position = CGPoint(x: -150, y: -60)
        leftArrow.zPosition = 10
        leftArrow.name = "leftArrow"
        addChild(leftArrow)

        // Current character
        let charLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        charLabel.text = "A"
        charLabel.fontSize = 48
        charLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        charLabel.position = CGPoint(x: 0, y: -60)
        charLabel.zPosition = 10
        charLabel.name = "currentChar"
        addChild(charLabel)
        characterLabels.append(charLabel)

        // Right arrow
        let rightArrow = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        rightArrow.text = ">"
        rightArrow.fontSize = 48
        rightArrow.fontColor = .white
        rightArrow.position = CGPoint(x: 150, y: -60)
        rightArrow.zPosition = 10
        rightArrow.name = "rightArrow"
        addChild(rightArrow)
    }

    private func updateNameDisplay() {
        var display = nameEntry
        let remaining = maxNameLength - nameEntry.count
        display += String(repeating: "_", count: remaining)
        nameLabel?.text = display
    }

    private func setupHighScoresDisplay() {
        let headerLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        headerLabel.text = "HIGH SCORES"
        headerLabel.fontSize = 28
        headerLabel.fontColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        headerLabel.position = CGPoint(x: 0, y: 50)
        headerLabel.zPosition = 10
        addChild(headerLabel)

        let scores = HighScoreManager.shared.getHighScores()
        let displayCount = min(5, scores.count)

        for i in 0..<displayCount {
            let entry = scores[i]
            let yPos = 10 - (i * 30)

            let rankLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
            rankLabel.text = "\(i + 1)."
            rankLabel.fontSize = 20
            rankLabel.fontColor = rankColor(for: i + 1)
            rankLabel.horizontalAlignmentMode = .right
            rankLabel.position = CGPoint(x: -150, y: yPos)
            rankLabel.zPosition = 10
            addChild(rankLabel)

            let nameLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
            nameLabel.text = String(entry.name.prefix(10))
            nameLabel.fontSize = 20
            nameLabel.fontColor = .white
            nameLabel.horizontalAlignmentMode = .left
            nameLabel.position = CGPoint(x: -120, y: yPos)
            nameLabel.zPosition = 10
            addChild(nameLabel)

            let scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
            scoreLabel.text = "$\(entry.score).00"
            scoreLabel.fontSize = 20
            scoreLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            scoreLabel.horizontalAlignmentMode = .right
            scoreLabel.position = CGPoint(x: 150, y: yPos)
            scoreLabel.zPosition = 10
            addChild(scoreLabel)
        }
    }

    private func rankColor(for rank: Int) -> SKColor {
        switch rank {
        case 1: return SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        case 2: return SKColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        case 3: return SKColor(red: 0.80, green: 0.50, blue: 0.20, alpha: 1.0)
        default: return SKColor.white
        }
    }

    private func setupContinuePrompt() {
        let continueLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        continueLabel.text = "TAP TO CONTINUE"
        continueLabel.fontSize = 24
        continueLabel.fontColor = .white
        continueLabel.position = CGPoint(x: 0, y: -180)
        continueLabel.zPosition = 10
        continueLabel.name = "continuePrompt"
        addChild(continueLabel)

        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        continueLabel.run(SKAction.repeatForever(blink))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        if isEnteringName {
            handleNameEntryTouch(nodes: nodes, location: location)
        } else {
            goToMenu()
        }
    }

    private func handleNameEntryTouch(nodes: [SKNode], location: CGPoint) {
        for node in nodes {
            if node.name == "leftArrow" {
                currentCharIndex = (currentCharIndex - 1 + characters.count) % characters.count
                updateCharacterDisplay()
                return
            } else if node.name == "rightArrow" {
                currentCharIndex = (currentCharIndex + 1) % characters.count
                updateCharacterDisplay()
                return
            } else if node.name == "currentChar" {
                addCharacter()
                return
            } else if node.name == "backspace" {
                deleteLastCharacter()
                return
            } else if node.name == "doneButton" {
                submitScore()
                return
            }
        }

        // Tap zones for character selection
        if location.y > -100 && location.y < -20 {
            if location.x < -50 {
                currentCharIndex = (currentCharIndex - 1 + characters.count) % characters.count
                updateCharacterDisplay()
            } else if location.x > 50 {
                currentCharIndex = (currentCharIndex + 1) % characters.count
                updateCharacterDisplay()
            } else {
                addCharacter()
            }
        }
    }

    private func updateCharacterDisplay() {
        let index = characters.index(characters.startIndex, offsetBy: currentCharIndex)
        let char = String(characters[index])
        if let charLabel = childNode(withName: "currentChar") as? SKLabelNode {
            charLabel.text = char
        }
    }

    private func addCharacter() {
        guard nameEntry.count < maxNameLength else { return }
        let index = characters.index(characters.startIndex, offsetBy: currentCharIndex)
        nameEntry.append(characters[index])
        updateNameDisplay()
    }

    private func deleteLastCharacter() {
        guard !nameEntry.isEmpty else { return }
        nameEntry.removeLast()
        updateNameDisplay()
    }

    private func submitScore() {
        guard !hasSubmittedScore else { return }
        hasSubmittedScore = true

        let name = nameEntry.isEmpty ? "AAA" : nameEntry
        HighScoreManager.shared.addScore(name: name, score: finalScore)

        // Remove name entry UI
        isEnteringName = false
        removeAllChildren()

        backgroundColor = .black
        setupGameOver()
        setupScoreDisplay()
        setupHighScoresDisplay()
        setupContinuePrompt()
    }

    private func goToMenu() {
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .aspectFill
        menuScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(menuScene, transition: transition)
    }
}
