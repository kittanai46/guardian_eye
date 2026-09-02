import 'package:flutter/services.dart';

import '../models/security_event.dart';

class MonitorSnapshot {
  const MonitorSnapshot({
    required this.isMonitoring,
    required this.protectionEnabled,
    required this.isBeingRecorded,
    required this.platformName,
    required this.supportsScreenshotDetection,
    required this.supportsRecordingDetection,
  });

  final bool isMonitoring;
  final bool protectionEnabled;
  final bool isBeingRecorded;
  final String platformName;
  final bool supportsScreenshotDetection;
  final bool supportsRecordingDetection;

  factory MonitorSnapshot.fromMap(Map<Object?, Object?> map) {
    return MonitorSnapshot(
      isMonitoring: map['isMonitoring'] == true,
      protectionEnabled: map['protectionEnabled'] != false,
      isBeingRecorded: map['isBeingRecorded'] == true,
      platformName: map['platformName']?.toString() ?? 'Flutter preview',
      supportsScreenshotDetection: map['supportsScreenshotDetection'] == true,
      supportsRecordingDetection: map['supportsRecordingDetection'] == true,
    );
  }

  static const preview = MonitorSnapshot(
    isMonitoring: false,
    protectionEnabled: true,
    isBeingRecorded: false,
    platformName: 'Preview mode',
    supportsScreenshotDetection: false,
    supportsRecordingDetection: false,
  );
}

class SecurityMonitorService {
  static const _methods = MethodChannel('guardian_eye/monitor');
  static const _events = EventChannel('guardian_eye/events');

  Stream<SecurityEvent> get events => _events
      .receiveBroadcastStream()
      .map(
        (data) =>
            SecurityEvent.fromMap(Map<Object?, Object?>.from(data as Map)),
      )
      .handleError((Object _) {});

  Future<MonitorSnapshot> getSnapshot() async {
    try {
      final data = await _methods.invokeMapMethod<Object?, Object?>(
        'getStatus',
      );
      return data == null
          ? MonitorSnapshot.preview
          : MonitorSnapshot.fromMap(data);
    } on PlatformException {
      return MonitorSnapshot.preview;
    } on MissingPluginException {
      return MonitorSnapshot.preview;
    }
  }

  Future<List<SecurityEvent>> getHistory() async {
    try {
      final data =
          await _methods.invokeListMethod<Object?>('getHistory') ?? const [];
      return data
          .whereType<Map<Object?, Object?>>()
          .map(SecurityEvent.fromMap)
          .toList(growable: false);
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  Future<void> startMonitoring() => _invoke('startMonitoring');
  Future<void> stopMonitoring() => _invoke('stopMonitoring');
  Future<void> runQuickCheck() => _invoke('runQuickCheck');
  Future<void> clearHistory() => _invoke('clearHistory');
  Future<void> setProtectionEnabled(bool enabled) =>
      _invoke('setProtectionEnabled', {'enabled': enabled});

  Future<void> _invoke(String method, [Map<String, Object?>? arguments]) async {
    try {
      await _methods.invokeMethod<void>(method, arguments);
    } on PlatformException {
      // Native monitoring is unavailable in desktop/web preview builds.
    } on MissingPluginException {
      // Keep UI previews and widget tests functional on unsupported platforms.
    }
  }
}
