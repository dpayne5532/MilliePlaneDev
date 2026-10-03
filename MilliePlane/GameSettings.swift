//
//  GameSettings.swift
//  MilliePlane
//
//  Persistent player preferences (music and sound effects)
//

import Foundation

enum GameSettings {
    private static let musicKey = "MilliePlaneMusicOn"
    private static let soundKey = "MilliePlaneSoundOn"

    static var isMusicOn: Bool {
        get { UserDefaults.standard.object(forKey: musicKey) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: musicKey) }
    }

    static var isSoundOn: Bool {
        get { UserDefaults.standard.object(forKey: soundKey) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: soundKey) }
    }
}
