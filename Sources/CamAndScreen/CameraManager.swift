import AVFoundation
import Combine

/// Manages a live `AVCaptureSession` and lets the user flip between the
/// front (selfie) and back camera while the session keeps running.
final class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published var position: AVCaptureDevice.Position = .front
    @Published var permissionDenied = false

    private let sessionQueue = DispatchQueue(label: "com.camandscreen.session")
    private var currentInput: AVCaptureDeviceInput?

    override init() {
        super.init()
        checkPermissionsAndConfigure()
    }

    private func checkPermissionsAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.configureSession()
                } else {
                    DispatchQueue.main.async { self?.permissionDenied = true }
                }
            }
        default:
            DispatchQueue.main.async { self.permissionDenied = true }
        }
    }

    private func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            self.addInput(for: self.position)
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    private func addInput(for position: AVCaptureDevice.Position) {
        if let currentInput {
            session.removeInput(currentInput)
            self.currentInput = nil
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
        }
    }

    /// Toggles between the front and back camera while keeping the
    /// session running so the preview never freezes or goes black.
    func flipCamera() {
        sessionQueue.async {
            let newPosition: AVCaptureDevice.Position = self.position == .front ? .back : .front
            self.session.beginConfiguration()
            self.addInput(for: newPosition)
            self.session.commitConfiguration()

            DispatchQueue.main.async {
                self.position = newPosition
            }
        }
    }
}
