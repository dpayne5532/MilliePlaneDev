//
//  HighScoreManager.swift
//  MilliePlane
//
//  Manages persistent high scores with a 1980s arcade-style leaderboard
//

import Foundation

class HighScoreManager {
    static let shared = HighScoreManager()

    private let highScoresKey = "MilliePlaneHighScores"
    private let maxScores = 10

    struct ScoreEntry: Codable {
        let name: String
        let score: Int
        let date: Date
    }

    private init() {}

    func getHighScores() -> [ScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: highScoresKey),
              let scores = try? JSONDecoder().decode([ScoreEntry].self, from: data) else {
            return []
        }
        return scores.sorted { $0.score > $1.score }
    }

    func isHighScore(_ score: Int) -> Bool {
        let scores = getHighScores()
        if scores.count < maxScores {
            return score > 0
        }
        return score > (scores.last?.score ?? 0)
    }

    func getRank(for score: Int) -> Int? {
        let scores = getHighScores()
        for (index, entry) in scores.enumerated() {
            if score > entry.score {
                return index + 1
            }
        }
        if scores.count < maxScores && score > 0 {
            return scores.count + 1
        }
        return nil
    }

    @discardableResult
    func addScore(name: String, score: Int) -> Int? {
        var scores = getHighScores()
        let newEntry = ScoreEntry(name: name.uppercased(), score: score, date: Date())
        scores.append(newEntry)
        scores.sort { $0.score > $1.score }

        if scores.count > maxScores {
            scores = Array(scores.prefix(maxScores))
        }

        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: highScoresKey)
        }

        return scores.firstIndex(where: { $0.score == score && $0.name == name.uppercased() }).map { $0 + 1 }
    }

    func clearScores() {
        UserDefaults.standard.removeObject(forKey: highScoresKey)
    }
}
