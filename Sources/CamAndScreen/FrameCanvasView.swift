import SwiftUI
import PhotosUI

/// The "framing" half of the screen. Lets the user drop in a photo,
/// then pan and pinch-zoom it to frame exactly what they want captured
/// alongside the live camera feed when the recording is made.
struct FrameCanvasView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var image: Image?

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.09)

            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(dragAndZoomGesture)
            } else {
                emptyState
            }

            VStack {
                Spacer()
                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Frame a Photo", systemImage: "photo.on.rectangle")
                            .labelStyle(.titleAndIcon)
                            .font(.footnote.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                    }

                    if image != nil {
                        Button(action: resetTransform) {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                                .labelStyle(.titleAndIcon)
                                .font(.footnote.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, 16)
            }
        }
        .clipped()
        .onChange(of: selectedItem) { newItem in
            Task {
                guard let newItem,
                      let data = try? await newItem.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else { return }
                image = Image(uiImage: uiImage)
                resetTransform()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "rectangle.dashed")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.35))
            Text("Frame your content here")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.6))
            Text("Pick a photo, then pinch and drag to frame it")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
        }
    }

    private var dragAndZoomGesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = max(0.5, min(lastScale * value, 6))
                }
                .onEnded { _ in
                    lastScale = scale
                },
            DragGesture()
                .onChanged { value in
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
                .onEnded { _ in
                    lastOffset = offset
                }
        )
    }

    private func resetTransform() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }
}
