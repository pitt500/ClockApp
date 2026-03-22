//
//  FileTimersPersistence.swift
//  ClockApp
//
//  Created by Pedro Rojas on 23/02/26.
//


import Foundation

actor FileTimersPersistence: TimersPersistence {

    private struct Payload: Codable {
        var schemaVersion: Int
        var recents: [RecentDTO]
    }

    private struct RecentDTO: Codable {
        var durationInSeconds: Duration
        var label: String
    }

    private let schemaVersion = 1
    private let fileName = "timers-recents.json"

    func loadRecentTimers() async throws -> [TimerItem] {
        let url = try fileURL()

        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder().decode(Payload.self, from: data)

        // Future-proofing: schemaVersion is available if you evolve the format later.
        switch payload.schemaVersion {
        case 1:
            return try await withThrowingTaskGroup(of: TimerItem.self) { group in
                for dto in payload.recents {
                    group.addTask { [duration = dto.durationInSeconds, label = dto.label] in
                        await self.makeRecentTimerItem(duration: duration, label: label)
                    }
                }

                var items: [TimerItem] = []
                for try await item in group {
                    items.append(item)
                }
                return items
            }
        default:
            // Unknown schema. Fail soft by returning empty so the app remains usable.
            return []
        }
    }

    func saveRecentTimers(_ timers: [TimerItem]) async throws {
        let url = try fileURL()
        try ensureParentDirectoryExists(for: url)

        let recents = timers.map { item in
            RecentDTO(
                durationInSeconds: item.configuredDuration,
                label: item.label
            )
        }

        let payload = Payload(schemaVersion: schemaVersion, recents: recents)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(payload)

        // Atomic write avoids corruption on app kill / crash during write.
        try data.write(to: url, options: [.atomic])
    }

    // MARK: - Helpers

    private func makeRecentTimerItem(duration: Duration, label: String) async -> TimerItem {
        let manager = await MainActor.run { () -> TimerManager in
            let manager = TimerManager(label: label)
            manager.setPreset(totalTime: duration)
            return manager
        }

        return await TimerItem(
            label: label,
            configuredDuration: duration,
            manager: manager
        )
    }

    private func fileURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        // Keep files scoped to your bundle id folder for cleanliness.
        let bundleID = Bundle.main.bundleIdentifier ?? "ClockApp"
        let folder = base.appendingPathComponent(bundleID, isDirectory: true)

        return folder.appendingPathComponent(fileName, isDirectory: false)
    }

    private func ensureParentDirectoryExists(for url: URL) throws {
        let folder = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }
}
