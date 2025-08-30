//
//  PhotoItem.swift
//  photosync
//
//  Created by Matthew Dolan on 2025-08-29.
//

import Foundation

struct PhotoItem: Identifiable, Codable, Hashable {
    let id: UUID
    let localPath: String
    let createdAt: Date
    var state: State
    var attempts: Int
    var lastError: String?
    
    enum State: String, Codable {
        case pending
        case uploading
        case uploaded
        case failed
    }
}
