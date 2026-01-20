//
//  GameMode.swift
//  MilliePlane
//
//  Game mode configuration for different gameplay styles
//

import Foundation

enum GameMode {
    case endless      // Original mode - play until you crash
    case targetScore  // Race to reach target score

    var targetScore: Int {
        switch self {
        case .endless: return 0
        case .targetScore: return 25  // Collect 25 Millie Bucks
        }
    }

    var displayName: String {
        switch self {
        case .endless: return "ENDLESS MODE"
        case .targetScore: return "TARGET SCORE"
        }
    }

    var description: String {
        switch self {
        case .endless: return "Play until you crash"
        case .targetScore: return "Race to $\(targetScore)!"
        }
    }
}
