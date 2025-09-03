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
    private let log = Logger(subsystem: "com.matthewdolan.photosync", category: "viewmodel")
    
    // MARK: - Properties
    @Published var photoItems: [PhotoItem] = []
    
    private let localStore = LocalStore()
    private let queueStore = QueueStore()
    private let uploadService = UploadService()
    
    // MARK: - Init
    init() {
        photoItems = queueStore.load()
        
        Task {
            await uploadService.setOnUpdate { [weak self] updatedItems in
                    guard let self else { return }
                    self.photoItems = updatedItems
                    self.queueStore.save(updatedItems)
             
            }
                await uploadService.set(photoItems)
                await uploadService.kick()
        }
    }
    
    // MARK: - Public API
    func addPhoto(data: Data) async {
        do {
            let id = UUID()
            let photoFileURL = try localStore.saveJPEGAtomically(data, id: id)
            
            let newItem = PhotoItem(
                id: id,
                localPath: photoFileURL.path,
                createdAt: .now,
                uploadState: .pending,
                retryAttempts: 0,
                lastErrorMessage: nil
            )
            photoItems.insert(newItem, at: 0)
            queueStore.save(photoItems)
            await uploadService.set(photoItems)
            await uploadService.kick()
        } catch {
            // TODO: show error in UI
            log.error("Failed to save photo: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
}
