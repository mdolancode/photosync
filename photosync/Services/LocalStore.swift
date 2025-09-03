//
//  LocalStore.swift
//  photosync
//
//  Created by Matthew Dolan on 2025-08-29.
//

import Foundation

struct LocalStore {
    // MARK: - Directory Management
    func makePhotosDirectory() throws -> URL {
        let appSupportDirectory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        let photosDirectoryURL = appSupportDirectory.appendingPathComponent("Photos", isDirectory: true)
        try FileManager.default.createDirectory(at: photosDirectoryURL, withIntermediateDirectories: true)
        return photosDirectoryURL
    }
    
    // MARK: - Public API
    func saveJPEGAtomically(_ data: Data, id: UUID) throws -> URL {
        let photoFileURL = try makePhotosDirectory().appendingPathComponent("\(id.uuidString).jpg")
        try data.write(to: photoFileURL, options: [.atomic])
        return photoFileURL
    }
}
