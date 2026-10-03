//
//  GameScene.swift
//  MilliePlane
//
//  Core gameplay: flying, obstacles, Millie Bucks and power-ups
//

import AVFoundation
import SpriteKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "logoPlane")
    let music = SKAudioNode(fileNamed: "DangerZone.mp3")
    var scoreLabel = SKLabelNode(fontNamed: "Baskerville-Bold")
    var score = 0 {
        didSet {
            updateScoreDisplay()
            updateDifficulty()
            checkVictoryCondition()
        }
    }

    // Game Mode
    var gameMode: GameMode = .endless
    var lastUpdateTime: TimeInterval = 0
    var elapsedTime: TimeInterval = 0
    var timeLabel: SKLabelNode?
    var targetLabel: SKLabelNode?
    var isGameOver = false
    var isGamePaused = false

    // Difficulty ramps up every 10 Millie Bucks
    var difficultyLevel = 0
    let maxDifficultyLevel = 4
    var obstacleSpawnInterval: TimeInterval { 1.5 - 0.15 * Double(difficultyLevel) }
    var scrollDuration: TimeInterval { 9.0 - 0.75 * Double(difficultyLevel) }

    // Power-up state
    var isShieldActive = false
    var isMagnetActive = false
    var isMultiplierActive = false
    var shieldNode: SKShapeNode?
    var magnetTimeRemaining: TimeInterval = 0
    var multiplierTimeRemaining: TimeInterval = 0

    // HUD elements for power-ups
    var shieldIndicator: SKLabelNode?
    var magnetIndicator: SKLabelNode?
    var multiplierIndicator: SKLabelNode?

    // Constants
    let magnetRadius: CGFloat = 200
    let magnetForce: CGFloat = 300
    let obstacleSpawnKey = "spawnObstacles"

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
        setupPauseButton()

        if gameMode == .targetScore {
            setupTargetScoreHUD()
        }

        scheduleNextObstacle()
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self

        parallaxScroll(image: "sky", y: 0, z: -3, duration: 10, needsPhysics: false)
        parallaxScroll(image: "ground", y: -340, z: -1, duration: 6, needsPhysics: true)
        if GameSettings.isMusicOn {
            addChild(music)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive),
                                               name: UIScene.willDeactivateNotification, object: nil)
    }

    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self)
    }

    func appWillResignActive() {
        pauseGame()
    }

    private func playSound(_ fileName: String) {
        guard GameSettings.isSoundOn else { return }
        run(SKAction.playSoundFileNamed(fileName, waitForCompletion: false))
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

    private func setupPauseButton() {
        let button = SKNode()
        button.name = "pauseButton"
        button.position = CGPoint(x: -460, y: 320)
        button.zPosition = 100

        let circle = SKShapeNode(circleOfRadius: 26)
        circle.fillColor = UIColor.black.withAlphaComponent(0.3)
        circle.strokeColor = .white
        circle.lineWidth = 2
        button.addChild(circle)

        for x in [-7, 7] {
            let bar = SKShapeNode(rectOf: CGSize(width: 7, height: 22), cornerRadius: 2)
            bar.fillColor = .white
            bar.strokeColor = .clear
            bar.position.x = CGFloat(x)
            bar.zPosition = 1
            button.addChild(bar)
        }

        addChild(button)
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
            magnetIndicator?.text = "🧲\(Int(magnetTimeRemaining.rounded(.up)))s"
        } else {
            magnetIndicator?.fontColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.3)
            magnetIndicator?.text = "🧲"
        }

        // Update multiplier indicator
        if isMultiplierActive {
            multiplierIndicator?.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            multiplierIndicator?.text = "2X \(Int(multiplierTimeRemaining.rounded(.up)))s"
        } else {
            multiplierIndicator?.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.3)
            multiplierIndicator?.text = "2X"
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchedNames = nodes(at: touch.location(in: self)).flatMap { [$0.name, $0.parent?.name] }

        if isGamePaused {
            if touchedNames.contains("menuButton") {
                goToMenu()
            } else {
                resumeGame()
            }
            return
        }

        if touchedNames.contains("pauseButton") {
            pauseGame()
            return
        }

        player.physicsBody?.velocity = CGVector(dx: 0, dy: 300)
    }

    // MARK: - Pause

    private func pauseGame() {
        guard !isGamePaused && !isGameOver else { return }
        isGamePaused = true
        isPaused = true
        audioEngine.pause()

        let overlay = SKNode()
        overlay.name = "pauseOverlay"
        overlay.zPosition = 2000

        let dim = SKShapeNode(rectOf: CGSize(width: 2000, height: 2000))
        dim.fillColor = UIColor.black.withAlphaComponent(0.6)
        dim.strokeColor = .clear
        overlay.addChild(dim)

        let pausedLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        pausedLabel.text = "PAUSED"
        pausedLabel.fontSize = 72
        pausedLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        pausedLabel.position = CGPoint(x: 0, y: 60)
        pausedLabel.zPosition = 1
        overlay.addChild(pausedLabel)

        let resumeLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        resumeLabel.text = "TAP TO RESUME"
        resumeLabel.fontSize = 28
        resumeLabel.fontColor = .white
        resumeLabel.position = CGPoint(x: 0, y: 0)
        resumeLabel.zPosition = 1
        overlay.addChild(resumeLabel)

        let menuButton = SKNode()
        menuButton.name = "menuButton"
        menuButton.position = CGPoint(x: 0, y: -90)
        menuButton.zPosition = 1
        let menuBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        menuBackground.fillColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        menuBackground.strokeColor = .white
        menuBackground.lineWidth = 3
        menuButton.addChild(menuBackground)
        let menuLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        menuLabel.text = "QUIT TO MENU"
        menuLabel.fontSize = 20
        menuLabel.fontColor = .white
        menuLabel.verticalAlignmentMode = .center
        menuLabel.zPosition = 1
        menuButton.addChild(menuLabel)
        overlay.addChild(menuButton)

        addChild(overlay)
    }

    private func resumeGame() {
        guard isGamePaused else { return }
        isGamePaused = false
        isPaused = false
        try? audioEngine.start()
        childNode(withName: "pauseOverlay")?.removeFromParent()
    }

    private func goToMenu() {
        let menuScene = MenuScene(size: CGSize(width: 1024, height: 768))
        menuScene.scaleMode = .aspectFill
        menuScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        if isGamePaused {
            // SpriteKit un-pauses scenes when the app returns to the foreground; keep ours paused
            isPaused = true
            if audioEngine.isRunning { audioEngine.pause() }
            lastUpdateTime = 0
            return
        }

        // Frame delta, clamped so time spent paused or backgrounded doesn't count
        let deltaTime = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 0.1)
        lastUpdateTime = currentTime
        elapsedTime += deltaTime

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

        // Ease player rotation toward its velocity
        let targetAngle = player.physicsBody!.velocity.dy * 0.001
        player.zRotation += (targetAngle - player.zRotation) * min(1, CGFloat(deltaTime / 0.1))

        // Count down timed power-ups
        if isMagnetActive {
            magnetTimeRemaining -= deltaTime
            if magnetTimeRemaining <= 0 {
                deactivateMagnet()
            } else {
                applyMagnetEffect(deltaTime: CGFloat(deltaTime))
            }
        }

        if isMultiplierActive {
            multiplierTimeRemaining -= deltaTime
            if multiplierTimeRemaining <= 0 {
                deactivateMultiplier()
            }
        }

        // Update power-up HUD
        updatePowerUpHUD()
    }

    private func applyMagnetEffect(deltaTime: CGFloat) {
        let attractable = children.filter { $0.name == "score" || $0.name == GoldenHeart.nodeName }

        for node in attractable {
            let distance = hypot(node.position.x - player.position.x,
                                 node.position.y - player.position.y)

            if distance < magnetRadius && distance > 0 {
                // Calculate direction toward player
                let dx = player.position.x - node.position.x
                let dy = player.position.y - node.position.y

                // Normalize and apply force (stronger when closer)
                let strength = (magnetRadius - distance) / magnetRadius
                let normalizedDx = dx / distance * magnetForce * strength
                let normalizedDy = dy / distance * magnetForce * strength

                // Move toward player (its scroll action is relative, so the two combine)
                node.position.x += normalizedDx * deltaTime
                node.position.y += normalizedDy * deltaTime
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

    // MARK: - Spawning & Difficulty

    private func scheduleNextObstacle() {
        // SKActions (unlike Timers) pause along with the scene
        let spawn = SKAction.sequence([
            SKAction.wait(forDuration: obstacleSpawnInterval),
            SKAction.run { [weak self] in
                guard let self = self, !self.isGameOver else { return }
                self.createObstacle()
                self.scheduleNextObstacle()
            }
        ])
        run(spawn, withKey: obstacleSpawnKey)
    }

    private func updateDifficulty() {
        let newLevel = min(score / 10, maxDifficultyLevel)
        guard newLevel > difficultyLevel else { return }
        difficultyLevel = newLevel
        showBanner("FASTER!", color: SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0))
    }

    private func showBanner(_ text: String, color: SKColor) {
        let banner = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        banner.text = text
        banner.fontSize = 48
        banner.fontColor = color
        banner.position = CGPoint(x: 0, y: 180)
        banner.zPosition = 500
        banner.setScale(0.5)
        addChild(banner)
        banner.run(SKAction.sequence([
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 0.8),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
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
        let move = SKAction.moveBy(x: -1536, y: 0, duration: scrollDuration)
        let remove = SKAction.removeFromParent()
        let action = SKAction.sequence([move, remove])
        obstacle.run(action)

        // Spawn coin
        run(SKAction.wait(forDuration: 0.75)) { [weak self] in
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

        // Rarely, a golden heart for Grandma Karen
        if GoldenHeart.shouldSpawn() {
            spawnGoldenHeart(withAction: action)
        }
    }

    private func spawnGoldenHeart(withAction action: SKAction) {
        run(SKAction.wait(forDuration: 1.25)) { [weak self] in
            guard let self = self, !self.isGameOver else { return }

            let heart = GoldenHeart.createNode()
            heart.position.y = CGFloat.random(in: -250..<300)
            heart.position.x = 768
            heart.run(action)

            self.addChild(heart)
        }
    }

    private func spawnPowerUp(withAction action: SKAction) {
        run(SKAction.wait(forDuration: 1.0)) { [weak self] in
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
        } else if node.name == GoldenHeart.nodeName {
            handleGoldenHeartCollection(node)
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
        playSound("score.wav")
        node.removeFromParent()
        score += isMultiplierActive ? 2 : 1
    }

    private func handleGoldenHeartCollection(_ node: SKNode) {
        playSound("score.wav")
        let points = GoldenHeart.value * (isMultiplierActive ? 2 : 1)

        let sparkles = GoldenHeart.createSparkles()
        sparkles.position = node.position
        addChild(sparkles)

        let message = GoldenHeart.createCollectMessage(points: points)
        message.position = CGPoint(x: 0, y: 120)
        addChild(message)

        node.removeFromParent()
        score += points
    }

    private func handlePowerUpCollection(_ node: SKNode) {
        guard let nodeName = node.name else { return }

        playSound("score.wav")
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
    }

    private func deactivateMagnet() {
        isMagnetActive = false
        magnetTimeRemaining = 0
    }

    private func activateMultiplier() {
        isMultiplierActive = true
        multiplierTimeRemaining = PowerUpType.multiplier.duration
    }

    private func deactivateMultiplier() {
        isMultiplierActive = false
        multiplierTimeRemaining = 0
    }

    // MARK: - Victory Condition

    private func checkVictoryCondition() {
        guard gameMode == .targetScore && score >= gameMode.targetScore else { return }

        triggerVictory()
    }

    private func triggerVictory() {
        isGameOver = true
        removeAction(forKey: obstacleSpawnKey)

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
        run(SKAction.wait(forDuration: 2)) { [weak self] in
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
        removeAction(forKey: obstacleSpawnKey)

        if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
            explosion.position = player.position
            addChild(explosion)
        }
        playSound("explosion")
        player.removeFromParent()
        music.removeFromParent()

        run(SKAction.wait(forDuration: 2)) { [weak self] in
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
