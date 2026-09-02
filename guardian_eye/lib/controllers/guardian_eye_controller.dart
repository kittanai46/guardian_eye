import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/security_event.dart';
import '../services/security_monitor_service.dart';

class GuardianEyeController extends ChangeNotifier {
  GuardianEyeController({SecurityMonitorService? service})
    : _service = service ?? SecurityMonitorService();

  final SecurityMonitorService _service;
  StreamSubscription<SecurityEvent>? _eventSubscription;

  MonitorSnapshot snapshot = MonitorSnapshot.preview;
  List<SecurityEvent> events = const [];
  bool isBusy = true;

  Future<void> initialize() async {
    _eventSubscription = _service.events.listen((_) => refresh());
    await refresh();
  }

  Future<void> refresh() async {
    final results = await Future.wait<Object>([
      _service.getSnapshot(),
      _service.getHistory(),
    ]);
    snapshot = results[0] as MonitorSnapshot;
    events = results[1] as List<SecurityEvent>;
    isBusy = false;
    notifyListeners();
  }

  Future<void> setMonitoring(bool enabled) async {
    isBusy = true;
    notifyListeners();
    if (enabled) {
      await _service.startMonitoring();
    } else {
      await _service.stopMonitoring();
    }
    await refresh();
  }

  Future<void> runQuickCheck() async {
    isBusy = true;
    notifyListeners();
    await _service.runQuickCheck();
    await refresh();
  }

  Future<void> setProtection(bool enabled) async {
    await _service.setProtectionEnabled(enabled);
    await refresh();
  }

  Future<void> clearHistory() async {
    await _service.clearHistory();
    await refresh();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
