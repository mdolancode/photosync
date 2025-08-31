//
//  UploadService.swift
//  photosync
//
//  Created by Matthew Dolan on 2025-08-29.
//

import Foundation
import os

actor UploadService {
    private let log = Logger(subsystem: "com.matthewdolan.photosync", category: "uploader")
    private var items: [PhotoItem] = []
    private var onUpdate: (@Sendable ([PhotoItem]) -> Void)?
    
   func setOnUpdate(_ handler: @escaping @Sendable ([PhotoItem]) -> Void) {
       self.onUpdate = handler
    }
    
    func set(_ newItems: [PhotoItem]) {
        self.items = newItems
        notify()
    }
    
    private func notify() {
        guard let h = onUpdate else { return }
        Task { @MainActor [items] in
            h(items)
        }
    }
    
    func kick() async {
        let idxs = Array(items.indices)
        for idx in items.indices where items[idx].state == .pending || items[idx].state == .failed {
            await upload(index: idx)
        }
        notify()
    }
    
    private func upload(index: Int) async {
        guard items.indices.contains(index) else { return }
        
        items[index].state = .uploading
        notify()
        
        try? await Task.sleep(nanoseconds: 700_000_000)
        let success = Int.random(in: 0..<100) < 75
        
        if success {
            items[index].state = .uploaded
            items[index].lastError = nil
            notify()
        } else {
            items[index].state = .failed
            items[index].attempts += 1
            log.error("Upload failed for item \(self.items[index].id, privacy: .public), attempts: \(self.items[index].attempts)")
            notify()
            
            let delay = UInt64(min(4, Int(pow(2.0, Double(items[index].attempts))))) * 1_000_000_000
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: delay)
                await self?.upload(index: index)
            }
        }
    }
}
