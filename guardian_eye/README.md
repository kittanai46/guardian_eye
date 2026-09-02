# Guardian Eye

Guardian Eye is a privacy-monitoring Flutter app. The Android MVP provides a
visible background monitor, screen-capture protection, supported screenshot and
screen-recording callbacks, a local event timeline, and a home-screen widget.

## Run

```sh
flutter run
```

On Android, open the app once and allow notifications. Add the **Guardian Eye**
widget from the launcher's widget picker to start or stop monitoring from the
home screen.

## Android capability levels

- Android 15+ (API 35): detects when a Guardian Eye activity is visible in a
  screen recording or screen share.
- Android 14+ (API 34): detects screenshot attempts involving Guardian Eye.
- Android 7+ (API 24): supports the app UI, local event history, foreground
  monitor, widget, and `FLAG_SECURE` content protection.

Android does not expose a general-purpose API that lets a third-party app
identify every recorder or inspect arbitrary activity in other apps. Guardian
Eye only records event metadata and never captures screen content, audio, or
images.

## Verify

```sh
flutter analyze
flutter test
flutter build apk --debug
```
