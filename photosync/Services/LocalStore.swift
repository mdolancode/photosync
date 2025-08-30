//
//  LocalStore.swift
//  photosync
//
//  Created by Matthew Dolan on 2025-08-29.
//

import Foundation

struct LocalStore {
    func dir() throws -> URL {
        let base = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let d = base.appendingPathComponent("Photos", isDirectory: true)
        try FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }
    
    func saveJPEGAtomically(_ data: Data, id: UUID) throws -> URL {
        let url = try dir().appendingPathComponent("\(id.uuidString).jpg")
        try data.write(to: url, options: [.atomic])
        return url
    }
}
