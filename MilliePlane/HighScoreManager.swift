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
    private let targetScoreTimesKey = "MilliePlaneTargetScoreTimes"
    private let maxScores = 10

    struct ScoreEntry: Codable {
        let name: String
        let score: Int
        let date: Date
    }

    struct TimeEntry: Codable {
        let name: String
        let time: TimeInterval
        let date: Date
    }

    private init() {}

    // MARK: - Endless Mode High Scores

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

    // MARK: - Target Score Mode Times

    func getTargetScoreTimes() -> [TimeEntry] {
        guard let data = UserDefaults.standard.data(forKey: targetScoreTimesKey),
              let times = try? JSONDecoder().decode([TimeEntry].self, from: data) else {
            return []
        }
        // Sort by fastest time (ascending)
        return times.sorted { $0.time < $1.time }
    }

    func isTargetScoreRecord(_ time: TimeInterval) -> Bool {
        guard time > 0 else { return false }

        let times = getTargetScoreTimes()
        if times.count < maxScores {
            return true
        }
        // Check if this time is faster than the slowest recorded time
        return time < (times.last?.time ?? Double.infinity)
    }

    func getTargetScoreRank(for time: TimeInterval) -> Int? {
        let times = getTargetScoreTimes()
        for (index, entry) in times.enumerated() {
            if time < entry.time {
                return index + 1
            }
        }
        if times.count < maxScores && time > 0 {
            return times.count + 1
        }
        return nil
    }

    @discardableResult
    func addTargetScoreTime(name: String, time: TimeInterval) -> Int? {
        var times = getTargetScoreTimes()
        let newEntry = TimeEntry(name: name.uppercased(), time: time, date: Date())
        times.append(newEntry)
        // Sort by fastest time (ascending)
        times.sort { $0.time < $1.time }

        if times.count > maxScores {
            times = Array(times.prefix(maxScores))
        }

        if let data = try? JSONEncoder().encode(times) {
            UserDefaults.standard.set(data, forKey: targetScoreTimesKey)
        }

        return times.firstIndex(where: { $0.time == time && $0.name == name.uppercased() }).map { $0 + 1 }
    }

    func clearTargetScoreTimes() {
        UserDefaults.standard.removeObject(forKey: targetScoreTimesKey)
    }

    // MARK: - Clear All Data

    func clearAllData() {
        clearScores()
        clearTargetScoreTimes()
    }
}
