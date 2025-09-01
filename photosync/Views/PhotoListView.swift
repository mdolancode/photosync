//
//  PhotoListView.swift
//  photosync
//
//  Created by Matthew Dolan on 2025-08-30.
//

import SwiftUI
import PhotosUI

struct PhotoListView: View {
    @StateObject private var viewModel = PhotoListViewModel()
    @State private var pickedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.photoItems) { item in
                    PhotoRow(item: item)
                }
            }
            .navigationTitle("Photo Sync")
            .toolbar {
                PhotosPicker(selection: $pickedItem, matching: .images) {
                    Label("Add Photo", systemImage: "plus")
                }
            }
        }
        .onChange(of: pickedItem) { _, newValue in
            guard let newValue else { return }
            Task {
                
                if let data = try? await newValue.loadTransferable(type: Data.self) {
                    await viewModel.addPhoto(data: data)
                }
                pickedItem = nil
            }
        }
        
    }
}

private struct PhotoRow: View {
    let item: PhotoItem

    var shortId: String {
        // Make prefix a String explicitly to help the type-checker
        String(item.id.uuidString.prefix(8)) + "…"
    }

    var body: some View {
        HStack(spacing: 12) {
            PhotoThumbnail(path: item.localPath)
            VStack(alignment: .leading, spacing: 4) {
                Text(shortId)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                HStack(spacing: 8) {
                    StatusChip(state: item.uploadState)
                    if item.retryAttempts > 0 && item.uploadState != .uploaded {
                        Text("tries: \(item.retryAttempts)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct PhotoThumbnail: View {
    let path: String
    var body: some View {
        Group {
            if let img = UIImage(contentsOfFile: path) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .overlay(Image(systemName: "photo"))
            }
        }
        .frame(width: 56, height: 56)
        .clipped()
        .cornerRadius(8)
        .opacity(0.95)
    }
}

private struct StatusChip: View {
    let state: PhotoItem.UploadState
    var text: String {
        switch state {
        case .pending: return "Pending"
        case .uploading: return "Uploading"
        case .uploaded: return "Uploaded"
        case .failed: return "Failed"
        }
    }
    var body: some View {
        Text(text)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(foreground)
            .background(
                Capsule()
                    .fill(background)
                    .overlay(
                        Capsule().strokeBorder(border, lineWidth: 0.5)
                    )
                )
    }
                
    private var background: Color {
        switch state {
        case .pending: return .yellow.opacity(0.18)
        case .uploading: return .blue.opacity(0.18)
        case .uploaded: return .green.opacity(0.18)
        case .failed: return .red.opacity(0.18)
        }
    }
                
    private var border: Color {
        switch state {
        case .pending: return .yellow.opacity(0.5)
        case .uploading: return .blue.opacity(0.5)
        case .uploaded: return .green.opacity(0.5)
        case .failed: return .red.opacity(0.5)
        }
    }
                
    private var foreground: Color {
        switch state {
        case .pending: return .yellow
        case .uploading: return .blue
        case .uploaded: return .green
        case .failed: return .red
        }
    }
}
