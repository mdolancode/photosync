//
//  PhotoItem.swift
//  photosync
//
//  Created by Matthew Dolan on 2025-08-29.
//

import Foundation

struct PhotoItem: Identifiable, Codable, Hashable {
    // MARK: Model Properties
    let id: UUID
    let localPath: String
    let createdAt: Date
    var uploadState: UploadState
    var retryAttempts: Int
    var lastErrorMessage: String?
    
    // MARK: - State
    enum UploadState: String, Codable {
        case pending
        case uploading
        case uploaded
        case failed
    }
}
