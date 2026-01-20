//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "logoPlane")
    let music = SKAudioNode(fileNamed: "DangerZone.mp3")
    var obstacleTimer: Timer?
    var scoreLabel = SKLabelNode(fontNamed: "Baskerville-Bold")
    var score = 0 {
        didSet {
            updateScoreDisplay()
            checkVictoryCondition()
        }
    }

    // Game Mode
    var gameMode: GameMode = .endless
    var gameStartTime: TimeInterval = 0
    var elapsedTime: TimeInterval = 0
    var timeLabel: SKLabelNode?
    var targetLabel: SKLabelNode?
    var isGameOver = false

    // Power-up state
    var isShieldActive = false
    var isMagnetActive = false
    var isMultiplierActive = false
    var shieldNode: SKShapeNode?
    var magnetTimer: Timer?
    var multiplierTimer: Timer?
    var magnetTimeRemaining: TimeInterval = 0
    var multiplierTimeRemaining: TimeInterval = 0

    // HUD elements for power-ups
    var shieldIndicator: SKLabelNode?
    var magnetIndicator: SKLabelNode?
    var multiplierIndicator: SKLabelNode?

    // Constants
    let magnetRadius: CGFloat = 200
    let magnetForce: CGFloat = 300

    convenience init(gameMode: GameMode) {
        self.init(fileNamed: "GameScene")!
        self.gameMode = gameMode
    }

    override func didMove(to view: SKView) {
        player.position = CGPoint(x: -400, y: 250)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.collisionBitMask = 0
        addChild(player)

        setupScoreLabel()
        setupPowerUpHUD()

        if gameMode == .targetScore {
            setupTargetScoreHUD()
        }

        obstacleTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(createObstacle), userInfo: nil, repeats: true)
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self

        parallaxScroll(image: "sky", y: 0, z: -3, duration: 10, needsPhysics: false)
        parallaxScroll(image: "ground", y: -340, z: -1, duration: 6, needsPhysics: true)
        addChild(music)

        gameStartTime = 0
    }

    private func setupScoreLabel() {
        scoreLabel.fontColor = UIColor.black.withAlphaComponent(0.5)
        scoreLabel.position.y = 320
        addChild(scoreLabel)
        score = 0
    }

    private func setupPowerUpHUD() {
        // Shield indicator (top-right area)
        shieldIndicator = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        shieldIndicator?.fontSize = 24
        shieldIndicator?.fontColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.3)
        shieldIndicator?.position = CGPoint(x: 350, y: 320)
        shieldIndicator?.text = "🛡️"
        shieldIndicator?.zPosition = 100
        addChild(shieldIndicator!)

        // Magnet indicator
        magnetIndicator = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        magnetIndicator?.fontSize = 20
        magnetIndicator?.fontColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.3)
        magnetIndicator?.position = CGPoint(x: 400, y: 320)
        magnetIndicator?.text = "🧲"
        magnetIndicator?.zPosition = 100
        addChild(magnetIndicator!)

        // Multiplier indicator
        multiplierIndicator = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        multiplierIndicator?.fontSize = 20
        multiplierIndicator?.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.3)
        multiplierIndicator?.position = CGPoint(x: 450, y: 320)
        multiplierIndicator?.text = "2X"
        multiplierIndicator?.zPosition = 100
        addChild(multiplierIndicator!)
    }

    private func setupTargetScoreHUD() {
        // Time label
        timeLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        timeLabel?.fontSize = 20
        timeLabel?.fontColor = UIColor.white.withAlphaComponent(0.8)
        timeLabel?.position = CGPoint(x: -380, y: -320)
        timeLabel?.horizontalAlignmentMode = .left
        timeLabel?.text = "Time: 00:00"
        timeLabel?.zPosition = 100
        addChild(timeLabel!)

        // Target label
        targetLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        targetLabel?.fontSize = 20
        targetLabel?.fontColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        targetLabel?.position = CGPoint(x: 0, y: -320)
        targetLabel?.text = "Target: $0/$\(gameMode.targetScore)"
        targetLabel?.zPosition = 100
        addChild(targetLabel!)
    }

    private func updateScoreDisplay() {
        scoreLabel.text = "Millie Bucks:  $\(score).00"

        if gameMode == .targetScore {
            targetLabel?.text = "Target: $\(score)/$\(gameMode.targetScore)"
        }
    }

    private func updatePowerUpHUD() {
        // Update shield indicator
        shieldIndicator?.fontColor = isShieldActive ?
            SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0) :
            SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.3)

        // Update magnet indicator
        if isMagnetActive {
            magnetIndicator?.fontColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
            magnetIndicator?.text = "🧲\(Int(magnetTimeRemaining))s"
        } else {
            magnetIndicator?.fontColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.3)
            magnetIndicator?.text = "🧲"
        }

        // Update multiplier indicator
        if isMultiplierActive {
            multiplierIndicator?.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            multiplierIndicator?.text = "2X \(Int(multiplierTimeRemaining))s"
        } else {
            multiplierIndicator?.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.3)
            multiplierIndicator?.text = "2X"
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 300)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        // Track game time for target score mode
        if gameStartTime == 0 {
            gameStartTime = currentTime
        }
        elapsedTime = currentTime - gameStartTime

        // Update time display for target score mode
        if gameMode == .targetScore {
            let minutes = Int(elapsedTime) / 60
            let seconds = Int(elapsedTime) % 60
            timeLabel?.text = String(format: "Time: %02d:%02d", minutes, seconds)
        }

        // Constrain player position
        if player.position.y > 300 {
            player.position.y = 300
        }

        // Rotate player based on velocity
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        player.run(rotate)

        // Magnet effect - attract nearby coins
        if isMagnetActive {
            applyMagnetEffect()
        }

        // Update power-up HUD
        updatePowerUpHUD()
    }

    private func applyMagnetEffect() {
        enumerateChildNodes(withName: "score") { [weak self] node, _ in
            guard let self = self else { return }

            let distance = hypot(node.position.x - self.player.position.x,
                               node.position.y - self.player.position.y)

            if distance < self.magnetRadius {
                // Calculate direction toward player
                let dx = self.player.position.x - node.position.x
                let dy = self.player.position.y - node.position.y

                // Normalize and apply force (stronger when closer)
                let strength = (self.magnetRadius - distance) / self.magnetRadius
                let normalizedDx = dx / distance * self.magnetForce * strength
                let normalizedDy = dy / distance * self.magnetForce * strength

                // Move coin toward player
                let moveAction = SKAction.moveBy(x: normalizedDx * 0.016, y: normalizedDy * 0.016, duration: 0.016)
                node.run(moveAction)
            }
        }
    }

    func parallaxScroll(image: String, y: CGFloat, z: CGFloat, duration: Double, needsPhysics: Bool) {
        // run this code twice
        for i in 0...1 {
            let node = SKSpriteNode(imageNamed: image)


            node.position = CGPoint( x: 1023 * CGFloat(i), y: y)
            node.zPosition = z
            addChild(node)
            if needsPhysics {
                node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.texture!.size())
                node.physicsBody?.isDynamic = false
                node.physicsBody?.contactTestBitMask = 1
                node.name = "obstacle"
            }

            let move = SKAction.moveBy(x: -1024, y: 0, duration: duration)

            let wrap = SKAction.moveBy(x: 1024, y: 0, duration: 0)

            let sequence = SKAction.sequence([move, wrap])
            let forever = SKAction.repeatForever(sequence)

            node.run(forever)
        }
    }

    func createObstacle() {
        guard !isGameOver else { return }

        let obstacle = SKSpriteNode(imageNamed: "300")
        obstacle.zPosition = -1
        obstacle.position.x = 768
        addChild(obstacle)


        obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!, size: obstacle.texture!.size())
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.contactTestBitMask = 1
        obstacle.name = "obstacle"


        obstacle.position.y = CGFloat.random(in: -300..<350)
        let move = SKAction.moveTo(x: -768, duration: 9)
        let remove = SKAction.removeFromParent()
        let action = SKAction.sequence([move, remove])
        obstacle.run(action)

        // Spawn coin
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            guard let self = self, !self.isGameOver else { return }

            let coin = SKSpriteNode(imageNamed: "cash")
            coin.physicsBody = SKPhysicsBody(texture: coin.texture!, size: coin.texture!.size())
            coin.physicsBody?.contactTestBitMask = 1
            coin.physicsBody?.isDynamic = false
            coin.position.y = CGFloat.random(in: -300..<350)
            coin.position.x = 768
            coin.name = "score"
            coin.run(action)

            self.addChild(coin)
        }

        // Maybe spawn a power-up (10% chance)
        if PowerUp.shouldSpawn() {
            spawnPowerUp(withAction: action)
        }
    }

    private func spawnPowerUp(withAction action: SKAction) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, !self.isGameOver else { return }

            let powerUpType = PowerUp.randomType()
            let powerUpNode = PowerUp.createNode(type: powerUpType)
            powerUpNode.position.y = CGFloat.random(in: -250..<300)
            powerUpNode.position.x = 768
            powerUpNode.run(action)

            self.addChild(powerUpNode)
        }
    }

    func playerHit(_ node: SKNode) {
        guard !isGameOver else { return }

        if node.name == "obstacle" {
            handleObstacleCollision(node)
        } else if node.name == "score" {
            handleCoinCollection(node)
        } else if node.name?.starts(with: "powerup_") == true {
            handlePowerUpCollection(node)
        }
    }

    private func handleObstacleCollision(_ node: SKNode) {
        if isShieldActive {
            // Shield absorbs the hit
            consumeShield()
            return
        }

        // Game over
        triggerGameOver()
    }

    private func handleCoinCollection(_ node: SKNode) {
        run(SKAction.playSoundFileNamed("score.wav", waitForCompletion: false))
        node.removeFromParent()
        score += isMultiplierActive ? 2 : 1
    }

    private func handlePowerUpCollection(_ node: SKNode) {
        guard let nodeName = node.name else { return }

        run(SKAction.playSoundFileNamed("score.wav", waitForCompletion: false))
        node.removeFromParent()

        if nodeName == PowerUpType.shield.nodeName {
            activateShield()
        } else if nodeName == PowerUpType.magnet.nodeName {
            activateMagnet()
        } else if nodeName == PowerUpType.multiplier.nodeName {
            activateMultiplier()
        }
    }

    // MARK: - Power-Up Activation

    private func activateShield() {
        isShieldActive = true

        // Remove existing shield visual if any
        shieldNode?.removeFromParent()

        // Create shield visual around player
        shieldNode = SKShapeNode(circleOfRadius: 60)
        shieldNode?.fillColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.2)
        shieldNode?.strokeColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.8)
        shieldNode?.lineWidth = 3
        shieldNode?.glowWidth = 10
        shieldNode?.zPosition = 5

        if let shield = shieldNode {
            player.addChild(shield)

            // Pulsing animation
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
            shield.run(SKAction.repeatForever(pulse))
        }
    }

    private func consumeShield() {
        isShieldActive = false

        // Shield break effect
        if let shield = shieldNode {
            let breakEffect = SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3)
            ])
            shield.run(SKAction.sequence([breakEffect, SKAction.removeFromParent()]))
        }
        shieldNode = nil

        // Flash the screen briefly
        let flash = SKShapeNode(rectOf: CGSize(width: 2000, height: 2000))
        flash.fillColor = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.5)
        flash.strokeColor = .clear
        flash.zPosition = 1000
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    private func activateMagnet() {
        isMagnetActive = true
        magnetTimeRemaining = PowerUpType.magnet.duration

        // Cancel existing timer if any
        magnetTimer?.invalidate()

        // Start countdown timer
        magnetTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.magnetTimeRemaining -= 1

            if self.magnetTimeRemaining <= 0 {
                self.deactivateMagnet()
            }
        }
    }

    private func deactivateMagnet() {
        isMagnetActive = false
        magnetTimeRemaining = 0
        magnetTimer?.invalidate()
        magnetTimer = nil
    }

    private func activateMultiplier() {
        isMultiplierActive = true
        multiplierTimeRemaining = PowerUpType.multiplier.duration

        // Cancel existing timer if any
        multiplierTimer?.invalidate()

        // Start countdown timer
        multiplierTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.multiplierTimeRemaining -= 1

            if self.multiplierTimeRemaining <= 0 {
                self.deactivateMultiplier()
            }
        }
    }

    private func deactivateMultiplier() {
        isMultiplierActive = false
        multiplierTimeRemaining = 0
        multiplierTimer?.invalidate()
        multiplierTimer = nil
    }

    // MARK: - Victory Condition

    private func checkVictoryCondition() {
        guard gameMode == .targetScore && score >= gameMode.targetScore else { return }

        triggerVictory()
    }

    private func triggerVictory() {
        isGameOver = true
        obstacleTimer?.invalidate()
        magnetTimer?.invalidate()
        multiplierTimer?.invalidate()

        // Victory animation
        let victoryLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        victoryLabel.text = "VICTORY!"
        victoryLabel.fontSize = 72
        victoryLabel.fontColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        victoryLabel.position = CGPoint(x: 0, y: 0)
        victoryLabel.zPosition = 1000
        victoryLabel.setScale(0.1)
        addChild(victoryLabel)

        let scaleUp = SKAction.scale(to: 1.0, duration: 0.5)
        scaleUp.timingMode = .easeOut
        victoryLabel.run(scaleUp)

        // Transition to game over scene with victory state
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }

            let gameOverScene = GameOverScene(
                score: self.score,
                isVictory: true,
                completionTime: self.elapsedTime,
                gameMode: self.gameMode
            )
            gameOverScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(gameOverScene, transition: transition)
        }
    }

    private func triggerGameOver() {
        isGameOver = true
        obstacleTimer?.invalidate()
        magnetTimer?.invalidate()
        multiplierTimer?.invalidate()

        if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
            explosion.position = player.position
            addChild(explosion)
        }
        run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
        player.removeFromParent()
        music.removeFromParent()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }

            let gameOverScene = GameOverScene(
                score: self.score,
                isVictory: false,
                completionTime: nil,
                gameMode: self.gameMode
            )
            gameOverScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(gameOverScene, transition: transition)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerHit(nodeB)
        } else if nodeB == player {
            playerHit(nodeA)
        }
    }

}
