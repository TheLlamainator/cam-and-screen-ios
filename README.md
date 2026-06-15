# Cam & Screen

A SwiftUI iOS app that splits the screen into two halves:

- **Top half** — a live camera preview. Tap the flip button to switch
  between the front (selfie) and back camera at any time.
- **Bottom half** — a "framing" canvas. Drop in a photo and pinch/drag to
  position and zoom it exactly how you want it to appear.

Tap the record button to start a screen recording (via ReplayKit) that
captures both halves of the app exactly as they appear, including
microphone audio. When you stop, the video is saved to your Photos library.

## Project structure

- `project.yml` — [XcodeGen](https://github.com/yonaskolb/XcodeGen) spec used
  to generate the `.xcodeproj` (not committed to source control).
- `Sources/CamAndScreen/` — all Swift source files, `Info.plist`, and the
  app icon asset catalog.
- `.github/workflows/build-ios.yml` — GitHub Actions workflow that builds
  the app on a macOS runner.

## Building locally (on a Mac)

```bash
brew install xcodegen
xcodegen generate
open CamAndScreen.xcodeproj
```

Then run on a simulator or a connected device from Xcode (select your own
Apple ID / team under Signing & Capabilities for a device build).

## Building via GitHub Actions

Every push triggers `.github/workflows/build-ios.yml`, which:

1. Generates the Xcode project with XcodeGen.
2. Builds a **Simulator build** (`CamAndScreen-Simulator.zip`) — drag the
   `.app` onto a running iOS Simulator to install it.
3. Builds an **unsigned device build** (`CamAndScreen-unsigned.ipa`) — this
   needs to be re-signed with your own Apple ID/certificate (e.g. via
   Sideloadly, AltStore, or `xcodebuild -allowProvisioningUpdates` with your
   team) before it can be installed on a real iPhone, since Apple requires
   every app to be signed for device installation.

Both artifacts are uploaded as a single `CamAndScreen-builds` artifact on
the workflow run.
