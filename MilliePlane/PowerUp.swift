//
//  PowerUp.swift
//  MilliePlane
//
//  Power-up types and visual creation for the game
//

import SpriteKit

enum PowerUpType: CaseIterable {
    case shield      // Survives one collision
    case magnet      // Attracts coins for 8 seconds
    case multiplier  // 2x points for 10 seconds

    var duration: TimeInterval {
        switch self {
        case .shield: return 0  // Until used (one-time protection)
        case .magnet: return 8.0
        case .multiplier: return 10.0
        }
    }

    var color: SKColor {
        switch self {
        case .shield: return SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)  // Cyan
        case .magnet: return SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)  // Red
        case .multiplier: return SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)  // Gold
        }
    }

    var label: String {
        switch self {
        case .shield: return "S"
        case .magnet: return "M"
        case .multiplier: return "2X"
        }
    }

    var labelColor: SKColor {
        switch self {
        case .shield: return .white
        case .magnet: return .white
        case .multiplier: return .black
        }
    }

    var nodeName: String {
        switch self {
        case .shield: return "powerup_shield"
        case .magnet: return "powerup_magnet"
        case .multiplier: return "powerup_multiplier"
        }
    }

    var hudIcon: String {
        switch self {
        case .shield: return "🛡️"
        case .magnet: return "🧲"
        case .multiplier: return "2X"
        }
    }
}

class PowerUp {
    static let spawnChance: Double = 0.10  // 10% chance per obstacle spawn

    static func createNode(type: PowerUpType, scale: CGFloat = 1) -> SKNode {
        let container = SKNode()
        container.name = type.nodeName

        // Create the circle background
        let circle = SKShapeNode(circleOfRadius: 25 * scale)
        circle.fillColor = type.color
        circle.strokeColor = .white
        circle.lineWidth = 3
        circle.glowWidth = 5
        container.addChild(circle)

        // Create the label
        let label = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        label.text = type.label
        label.fontSize = (type.label == "2X" ? 18 : 24) * scale
        label.fontColor = type.labelColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        container.addChild(label)

        // Add physics body
        let physicsBody = SKPhysicsBody(circleOfRadius: 25 * scale)
        physicsBody.isDynamic = false
        physicsBody.contactTestBitMask = 1
        container.physicsBody = physicsBody

        // Add pulsing animation
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.4)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.4)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        container.run(SKAction.repeatForever(pulse))

        return container
    }

    static func shouldSpawn() -> Bool {
        return Double.random(in: 0..<1) < spawnChance
    }

    static func randomType() -> PowerUpType {
        return PowerUpType.allCases.randomElement()!
    }
}
