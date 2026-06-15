import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var screenRecorder = ScreenRecorder()

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                cameraHalf
                    .frame(height: geo.size.height / 2)
                    .clipped()

                FrameCanvasView()
                    .frame(height: geo.size.height / 2)
            }
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                recordButton
                    .padding(.bottom, 28)
            }
            .overlay(alignment: .top) {
                if let message = screenRecorder.statusMessage {
                    StatusBanner(text: message)
                        .padding(.top, 56)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                if screenRecorder.statusMessage == message {
                                    screenRecorder.statusMessage = nil
                                }
                            }
                        }
                }
            }
        }
        .background(Color.black)
        .animation(.default, value: screenRecorder.statusMessage)
    }

    private var cameraHalf: some View {
        ZStack(alignment: .topTrailing) {
            if cameraManager.permissionDenied {
                VStack(spacing: 8) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.6))
                    Text("Camera access is required")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            } else {
                CameraPreviewView(session: cameraManager.session)
            }

            Button(action: cameraManager.flipCamera) {
                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.black.opacity(0.4), in: Circle())
            }
            .padding()
        }
    }

    private var recordButton: some View {
        Button(action: screenRecorder.toggleRecording) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 4)
                    .frame(width: 74, height: 74)

                if screenRecorder.isRecording {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                } else {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 60, height: 60)
                }
            }
        }
        .accessibilityLabel(screenRecorder.isRecording ? "Stop Recording" : "Start Recording")
    }
}

private struct StatusBanner: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.black.opacity(0.6), in: Capsule())
    }
}

#Preview {
    ContentView()
}
