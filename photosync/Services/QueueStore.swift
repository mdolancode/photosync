//
//  QueueStore.swift
//  photosync
//
//  Created by Matthew Dolan on 2025-08-29.
//

import Foundation

final class QueueStore {
    private let queueFileURL: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("queue.json")
    }()
    
    func load() -> [PhotoItem] {
        guard let data = try? Data(contentsOf: queueFileURL) else { return [] }
        return (try? JSONDecoder().decode([PhotoItem].self, from: data)) ?? []
    }
    
    func save(_ items: [PhotoItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: queueFileURL, options: [.atomic])
    }
}

