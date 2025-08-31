//
//  PhotoListViewModel.swift
//  photosync
//
//  Created by Matthew Dolan on 2025-08-29.
//

import SwiftUI
import os

@MainActor
final class PhotoListViewModel: ObservableObject {
    private let log = Logger(subsystem: "com.yourcompany.photosync", category: "viewmodel")
    @Published var items: [PhotoItem] = []
    
    private let local = LocalStore()
    private let queue = QueueStore()
    private let uploader = UploadService()
    
    init() {
        items = queue.load()
        
        Task {
            await uploader.setOnUpdate { [weak self] updated in
                Task { @MainActor in
                    guard let self else { return }
                    self.items = updated
                    self.queue.save(updated)
                }
            }
                await uploader.set(items)
                await uploader.kick()
        }
    }
    
    func addPhoto(data: Data) async {
        do {
            let id = UUID()
            let url = try local.saveJPEGAtomically(data, id: id)
            let newItem = PhotoItem(id: id,
                                    localPath: url.path,
                                    createdAt: .now,
                                    state: .pending,
                                    attempts: 0,
                                    lastError: nil)
            items.insert(newItem, at: 0)
            queue.save(items)
            await uploader.set(items)
            await uploader.kick()
        } catch {
            // TODO: show error in UI
            log.error("Failed to save photo: \(error.localizedDescription)")
        }
    }
}
