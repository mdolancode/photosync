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
    
    private let successRatePercent = 75
    private let maxBackoffDelaySeconds: UInt64 = 4
    private let baseUploadDelayNanoseconds: UInt64 = 700_000_000
    
    private var photoItems: [PhotoItem] = []
    private var onUpdate: (@Sendable ([PhotoItem]) -> Void)?
    
    func setOnUpdate(_ handler: @escaping @Sendable ([PhotoItem]) -> Void) {
        self.onUpdate = handler
    }
    
    func set(_ newItems: [PhotoItem]) {
        self.photoItems = newItems
        notify()
    }
    
    private func notify() {
        guard let updateHandler = onUpdate else { return }
        Task { @MainActor [photoItems] in
            updateHandler(photoItems)
        }
    }
    
    func kick() async {
        let indices = Array(photoItems.indices)
        for index in indices
        where photoItems[index].state == .pending || photoItems[index].state == .failed {
            await upload(index: index)
        }
        notify()
    }
    
    private func upload(index: Int) async {
        guard photoItems.indices.contains(index) else { return }
        
        photoItems[index].state = .uploading
        notify()
        
        try? await Task.sleep(nanoseconds: 700_000_000)
        let success = Int.random(in: 0..<100) < 75
        
        if success {
            photoItems[index].state = .uploaded
            photoItems[index].lastError = nil
            notify()
            return
        }
        
        photoItems[index].state = .failed
        photoItems[index].attempts += 1
        let itemId = photoItems[index].id
        log.error("Upload failed for item \(self.photoItems[index].id, privacy: .public), attempts: \(self.photoItems[index].attempts)")
        notify()
        
        let attempts = photoItems[index].attempts
        let seconds = min(maxBackoffDelaySeconds, UInt64(1 << min(attempts, 30)))
        let delayNanoseconds = seconds * 1_000_000_000
     
        Task {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
            await self.retryUpload(for: itemId)
        }
        
    }
    private func retryUpload(for id: UUID) async {
        guard let index = photoItems.firstIndex(where: { $0.id == id }) else { return }
        guard photoItems[index].state == .failed || photoItems[index].state == .pending else { return }
        await upload(index: index)
    }
}
