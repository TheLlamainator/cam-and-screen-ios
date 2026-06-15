import ReplayKit
import Photos
import Combine

/// Records the app's own screen (camera half + framed content half) with
/// ReplayKit and saves the result to the Photos library.
final class ScreenRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var statusMessage: String?

    private let recorder = RPScreenRecorder.shared()

    func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        guard recorder.isAvailable else {
            statusMessage = "Screen recording isn't available on this device."
            return
        }

        recorder.isMicrophoneEnabled = true
        recorder.startRecording { [weak self] error in
            DispatchQueue.main.async {
                if let error {
                    self?.statusMessage = error.localizedDescription
                    self?.isRecording = false
                } else {
                    self?.isRecording = true
                    self?.statusMessage = nil
                }
            }
        }
    }

    private func stopRecording() {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("CamAndScreen-\(UUID().uuidString).mp4")

        recorder.stopRecording(withOutput: outputURL) { [weak self] error in
            DispatchQueue.main.async {
                self?.isRecording = false

                if let error {
                    self?.statusMessage = error.localizedDescription
                    return
                }

                self?.saveToPhotos(url: outputURL)
            }
        }
    }

    private func saveToPhotos(url: URL) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    self?.statusMessage = "Allow Photos access to save your recording."
                }
                try? FileManager.default.removeItem(at: url)
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, error in
                DispatchQueue.main.async {
                    self?.statusMessage = success
                        ? "Recording saved to Photos!"
                        : (error?.localizedDescription ?? "Failed to save recording.")
                }
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
}
