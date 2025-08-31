# PhotoSync – Local-First Upload Demo

This project is a small SwiftUI/iOS demo app that shows how to **capture photos, save them locally first, and then upload them reliably** with retry/backoff logic.  
It was built as a time-boxed exercise (~2 hours) to demonstrate approach, coding style, and familiarity with modern Swift concurrency.

---

## ✨ Features

- **MVVM Structure**  
  - `PhotoItem` model with state (`pending`, `uploading`, `uploaded`, `failed`)  
  - `QueueStore` for JSON-backed persistence  
  - `UploadService` actor for concurrency-safe uploads  
  - `PhotoListViewModel` coordinating persistence + uploads  
  - `PhotoListView` showing thumbnails, IDs, and status chips  

- **Local-First Reliability**  
  - Photos are saved atomically to the app’s Documents folder before upload  
  - Queue persisted in JSON (`queue.json`)  
  - Ensures no data loss even if app is killed mid-upload  

- **Uploader Simulation**  
  - Randomized 75% success chance  
  - Exponential backoff retry on failure (capped)  
  - Updates pushed back to the UI via `os.Logger` for visibility  

- **UI**  
  - SwiftUI list with status chips  
  - `PhotosPicker` integration  
  - Live status updates (pending → uploading → uploaded/failed)  

---

## 🛠️ How to Run

1. Clone the repo  
   ```bash
   git clone https://github.com/YOUR_USERNAME/photosync.git
   cd photosync
   ```

2. Open in Xcode 15 or later
   ```bash
   open photosync.xcodeproj
   ```

4. Build & run on iOS 17+ Simulator (or device).
    Tap Add Photo, pick from your library, and watch the upload lifecycle.

## 🚀 With More Time

If this were going into production, next steps would include:
	-	Integrating S3 (or iCloud) with presigned URLs instead of a simulated uploader
	-	Using background URLSession for resilient uploads even if the app is suspended
	-	Adding unit tests for state transitions and persistence
	-	Improving error handling & UI (e.g. progress indicators, manual retry button)
	-	Better handling of security-scoped bookmarks for provider URLs

## 📂 Project Structure

photosync/
 ├─ Models/          # Data models
 ├─ Services/        # LocalStore, QueueStore, UploadService
 ├─ ViewModels/      # PhotoListViewModel
 ├─ Views/           # PhotoListView (+ subviews)
 └─ PhotoSyncApp.swift

## 📝 Notes
	-	Built with Swift 6 / SwiftUI / Xcode 15
	-	Uses actors for concurrency safety
	-	Logs via os.Logger (viewable in Console.app under subsystem com.matthewdolan.photosync)

