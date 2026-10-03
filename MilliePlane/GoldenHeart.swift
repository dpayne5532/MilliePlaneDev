//
//  GoldenHeart.swift
//  MilliePlane
//
//  A rare golden heart in memory of Grandma Karen, worth bonus Millie Bucks
//

import SpriteKit

enum GoldenHeart {
    static let nodeName = "goldenHeart"
    static let spawnChance: Double = 0.04  // 4% chance per obstacle spawn
    static let value = 5

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

    /// Floating "For Grandma Karen" message shown when a heart is collected
    static func createCollectMessage(points: Int) -> SKNode {
        let container = SKNode()
        container.zPosition = 500

        let tribute = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        tribute.text = "♥ For Grandma Karen ♥"
        tribute.fontSize = 26
        tribute.fontColor = lavender
        tribute.verticalAlignmentMode = .center
        container.addChild(tribute)

        let bonus = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        bonus.text = "+$\(points).00"
        bonus.fontSize = 22
        bonus.fontColor = gold
        bonus.position = CGPoint(x: 0, y: -30)
        bonus.verticalAlignmentMode = .center
        container.addChild(bonus)

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
