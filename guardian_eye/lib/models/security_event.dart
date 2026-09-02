enum SecurityEventType {
  screenshot,
  screenRecording,
  quickCheck,
  monitorStarted,
  monitorStopped,
  warning,
}

enum SecuritySeverity { info, medium, high }

class SecurityEvent {
  const SecurityEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.occurredAt,
    required this.title,
    required this.description,
  });

  final String id;
  final SecurityEventType type;
  final SecuritySeverity severity;
  final DateTime occurredAt;
  final String title;
  final String description;

  factory SecurityEvent.fromMap(Map<Object?, Object?> map) {
    final typeName = map['type']?.toString() ?? 'warning';
    final severityName = map['severity']?.toString() ?? 'info';
    return SecurityEvent(
      id:
          map['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: SecurityEventType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => SecurityEventType.warning,
      ),
      severity: SecuritySeverity.values.firstWhere(
        (value) => value.name == severityName,
        orElse: () => SecuritySeverity.info,
      ),
      occurredAt:
          DateTime.tryParse(map['occurredAt']?.toString() ?? '') ??
          DateTime.now(),
      title: map['title']?.toString() ?? 'เหตุการณ์ความปลอดภัย',
      description: map['description']?.toString() ?? '',
    );
  }
}
