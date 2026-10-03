//
//  GoldenHeart.swift
//  MilliePlane
//
//  A rare golden heart from Grandma Karen, worth $10 Millie Bucks
//

import SpriteKit

enum GoldenHeart {
    static let nodeName = "goldenHeart"
    static let spawnChance: Double = 0.04  // 4% chance per obstacle spawn
    static let value = 10

    static let gold = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
    static let lavender = SKColor(red: 0.85, green: 0.75, blue: 1.0, alpha: 1.0)

    static func shouldSpawn() -> Bool {
        return Double.random(in: 0..<1) < spawnChance
    }

    static func createNode() -> SKNode {
        let container = SKNode()
        container.name = nodeName

        let heart = SKShapeNode(path: heartPath(size: 26))
        heart.fillColor = gold
        heart.strokeColor = .white
        heart.lineWidth = 3
        heart.glowWidth = 8
        container.addChild(heart)

        let physicsBody = SKPhysicsBody(circleOfRadius: 24)
        physicsBody.isDynamic = false
        physicsBody.contactTestBitMask = 1
        container.physicsBody = physicsBody

        // Gentle heartbeat
        let beat = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.15),
            SKAction.scale(to: 1.15, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.15),
            SKAction.wait(forDuration: 0.6)
        ])
        container.run(SKAction.repeatForever(beat))

        return container
    }

    /// Floating "$10.00 From Grandma Karen" message shown when a heart is collected
    static func createCollectMessage(points: Int) -> SKNode {
        let container = SKNode()
        container.zPosition = 500

        // Soft backdrop so the message reads clearly against the bright sky
        let backdrop = SKShapeNode(rectOf: CGSize(width: 360, height: 96), cornerRadius: 18)
        backdrop.fillColor = SKColor(red: 0.15, green: 0.05, blue: 0.25, alpha: 0.75)
        backdrop.strokeColor = gold
        backdrop.lineWidth = 2
        backdrop.position = CGPoint(x: 0, y: -19)
        container.addChild(backdrop)

        let amount = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        amount.text = "$\(points).00"
        amount.fontSize = 40
        amount.fontColor = gold
        amount.verticalAlignmentMode = .center
        amount.zPosition = 1
        container.addChild(amount)

        let tribute = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        tribute.text = "From Grandma Karen ♥"
        tribute.fontSize = 26
        tribute.fontColor = lavender
        tribute.position = CGPoint(x: 0, y: -38)
        tribute.verticalAlignmentMode = .center
        tribute.zPosition = 1
        container.addChild(tribute)

        container.setScale(0.5)
        container.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.moveBy(x: 0, y: 40, duration: 0.3)
            ]),
            SKAction.wait(forDuration: 1.2),
            SKAction.group([
                SKAction.moveBy(x: 0, y: 40, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6)
            ]),
            SKAction.removeFromParent()
        ]))

        return container
    }

    /// Burst of golden sparkles
    static func createSparkles() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "spark")
        emitter.particleBirthRate = 400
        emitter.numParticlesToEmit = 60
        emitter.particleLifetime = 0.8
        emitter.particleSpeed = 220
        emitter.particleSpeedRange = 120
        emitter.emissionAngleRange = .pi * 2
        emitter.particleAlphaSpeed = -1.2
        emitter.particleScale = 0.25
        emitter.particleScaleRange = 0.15
        emitter.particleColor = gold
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.zPosition = 400
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.removeFromParent()
        ]))
        return emitter
    }

    private static func heartPath(size s: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: -s))
        path.addCurve(to: CGPoint(x: -s, y: s * 0.25),
                      control1: CGPoint(x: -s * 0.5, y: -s * 0.5),
                      control2: CGPoint(x: -s, y: -s * 0.2))
        path.addCurve(to: CGPoint(x: 0, y: s * 0.5),
                      control1: CGPoint(x: -s, y: s * 0.8),
                      control2: CGPoint(x: -s * 0.25, y: s * 1.05))
        path.addCurve(to: CGPoint(x: s, y: s * 0.25),
                      control1: CGPoint(x: s * 0.25, y: s * 1.05),
                      control2: CGPoint(x: s, y: s * 0.8))
        path.addCurve(to: CGPoint(x: 0, y: -s),
                      control1: CGPoint(x: s, y: -s * 0.2),
                      control2: CGPoint(x: s * 0.5, y: -s * 0.5))
        path.closeSubpath()
        return path
    }
}
