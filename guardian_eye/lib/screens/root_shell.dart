import 'package:flutter/material.dart';

import '../controllers/guardian_eye_controller.dart';
import '../models/security_event.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.controller});

  final GuardianEyeController controller;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final pages = [
          _Dashboard(controller: widget.controller),
          _SecurityCheck(controller: widget.controller),
          _ActivityHistory(controller: widget.controller),
          _Settings(controller: widget.controller),
        ];
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.visibility_rounded, color: Color(0xFF35E5A1)),
                SizedBox(width: 10),
                Text(
                  'Guardian Eye',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'รีเฟรช',
                onPressed: widget.controller.refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: IndexedStack(index: _index, children: pages),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.shield_outlined),
                selectedIcon: Icon(Icons.shield),
                label: 'หน้าหลัก',
              ),
              NavigationDestination(
                icon: Icon(Icons.policy_outlined),
                selectedIcon: Icon(Icons.policy),
                label: 'ตรวจสอบ',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_rounded),
                label: 'เหตุการณ์',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'ตั้งค่า',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.onRefresh, required this.children});

  final Future<void> Function() onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: children,
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.controller});
  final GuardianEyeController controller;

  @override
  Widget build(BuildContext context) {
    final snapshot = controller.snapshot;
    final danger = snapshot.isBeingRecorded;
    final active = snapshot.isMonitoring;
    final color = danger
        ? const Color(0xFFFF667A)
        : active
        ? const Color(0xFF35E5A1)
        : const Color(0xFFFFC857);
    final title = danger
        ? 'ตรวจพบการบันทึกหน้าจอ'
        : active
        ? 'กำลังปกป้องอุปกรณ์'
        : 'ระบบตรวจสอบหยุดอยู่';

    return _PageBody(
      onRefresh: controller.refresh,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: .12),
                    border: Border.all(
                      color: color.withValues(alpha: .65),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    danger ? Icons.warning_rounded : Icons.shield_rounded,
                    size: 54,
                    color: color,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  active
                      ? 'Guardian Eye ทำงานเบื้องหลังและพร้อมแจ้งเตือน'
                      : 'เปิดการตรวจสอบเพื่อเริ่มเฝ้าระวัง',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: .65)),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: controller.isBusy
                        ? null
                        : () => controller.setMonitoring(!active),
                    icon: controller.isBusy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            active
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                          ),
                    label: Text(active ? 'หยุดการตรวจสอบ' : 'เริ่มการตรวจสอบ'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'เหตุการณ์',
                value: '${controller.events.length}',
                icon: Icons.receipt_long_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Metric(
                label: 'การป้องกัน',
                value: snapshot.protectionEnabled ? 'เปิด' : 'ปิด',
                icon: Icons.lock_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'ตรวจสอบด่วน',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            leading: const CircleAvatar(child: Icon(Icons.radar_rounded)),
            title: const Text('สแกนสถานะปัจจุบัน'),
            subtitle: const Text('ตรวจ API และสถานะการป้องกันที่พร้อมใช้งาน'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: controller.isBusy ? null : controller.runQuickCheck,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'แพลตฟอร์ม: ${snapshot.platformName}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: .6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityCheck extends StatelessWidget {
  const _SecurityCheck({required this.controller});
  final GuardianEyeController controller;

  @override
  Widget build(BuildContext context) {
    final snapshot = controller.snapshot;
    return _PageBody(
      onRefresh: controller.refresh,
      children: [
        Text(
          'Security Check',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text('ความสามารถจริงขึ้นอยู่กับเวอร์ชัน Android ของอุปกรณ์'),
        const SizedBox(height: 20),
        _CheckTile(
          title: 'ตรวจจับภาพหน้าจอ',
          description: snapshot.supportsScreenshotDetection
              ? 'รองรับโดย Android เวอร์ชันนี้'
              : 'ต้องใช้ Android 14 หรือใหม่กว่า',
          ready: snapshot.supportsScreenshotDetection,
        ),
        _CheckTile(
          title: 'ตรวจจับการบันทึกหรือแชร์จอ',
          description: snapshot.supportsRecordingDetection
              ? 'รองรับเมื่อหน้าต่างแอปถูกบันทึก'
              : 'ต้องใช้ Android 15 หรือใหม่กว่า',
          ready: snapshot.supportsRecordingDetection,
        ),
        _CheckTile(
          title: 'ป้องกันเนื้อหาสำคัญ',
          description: snapshot.protectionEnabled
              ? 'บล็อก screenshot และจอที่ไม่ปลอดภัย'
              : 'ปิดอยู่ในการตั้งค่า',
          ready: snapshot.protectionEnabled,
        ),
        _CheckTile(
          title: 'Background Monitor',
          description: snapshot.isMonitoring
              ? 'บริการกำลังทำงานและมี notification แสดงอยู่'
              : 'ยังไม่ได้เริ่มบริการ',
          ready: snapshot.isMonitoring,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: controller.isBusy ? null : controller.runQuickCheck,
          icon: const Icon(Icons.radar_rounded),
          label: const Text('ตรวจสอบอีกครั้ง'),
        ),
      ],
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.title,
    required this.description,
    required this.ready,
  });
  final String title;
  final String description;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final color = ready ? const Color(0xFF35E5A1) : const Color(0xFFFFC857);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: Icon(
          ready ? Icons.check_circle_rounded : Icons.info_rounded,
          color: color,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(description),
      ),
    );
  }
}

class _ActivityHistory extends StatelessWidget {
  const _ActivityHistory({required this.controller});
  final GuardianEyeController controller;

  @override
  Widget build(BuildContext context) {
    final events = controller.events;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ประวัติเหตุการณ์',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (events.isNotEmpty)
                TextButton(
                  onPressed: controller.clearHistory,
                  child: const Text('ล้างทั้งหมด'),
                ),
            ],
          ),
        ),
        Expanded(
          child: events.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        size: 56,
                        color: Colors.white38,
                      ),
                      SizedBox(height: 12),
                      Text('ยังไม่มีเหตุการณ์'),
                      Text(
                        'เหตุการณ์ที่ตรวจพบจะแสดงที่นี่',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  itemCount: events.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _EventTile(event: events[index]),
                ),
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final SecurityEvent event;

  @override
  Widget build(BuildContext context) {
    final color = switch (event.severity) {
      SecuritySeverity.high => const Color(0xFFFF667A),
      SecuritySeverity.medium => const Color(0xFFFFC857),
      SecuritySeverity.info => const Color(0xFF35E5A1),
    };
    final local = event.occurredAt.toLocal();
    final time =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 4,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${event.description}\n$time'),
        isThreeLine: true,
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings({required this.controller});
  final GuardianEyeController controller;

  @override
  Widget build(BuildContext context) {
    return _PageBody(
      onRefresh: controller.refresh,
      children: [
        Text(
          'ตั้งค่า',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                value: controller.snapshot.protectionEnabled,
                onChanged: controller.setProtection,
                secondary: const Icon(Icons.screenshot_monitor_rounded),
                title: const Text('ป้องกันการจับภาพหน้าจอ'),
                subtitle: const Text(
                  'ทำให้ภาพจาก Guardian Eye เป็นหน้าว่างบน Android',
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: controller.snapshot.isMonitoring,
                onChanged: controller.setMonitoring,
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('ทำงานเบื้องหลัง'),
                subtitle: const Text('แสดง notification ขณะระบบทำงาน'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: const Column(
            children: [
              ListTile(
                leading: Icon(Icons.widgets_outlined),
                title: Text('วิดเจ็ตหน้าจอหลัก'),
                subtitle: Text(
                  'เพิ่มจากเมนู Widgets ของ Android แล้วแตะเพื่อเริ่มหรือหยุดตรวจสอบ',
                ),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.storage_outlined),
                title: Text('การจัดเก็บข้อมูล'),
                subtitle: Text('เก็บเฉพาะ metadata ของเหตุการณ์ภายในเครื่อง'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.verified_user_outlined),
                title: Text('ความเป็นส่วนตัว'),
                subtitle: Text('ไม่มีการบันทึกภาพ เสียง หรือเนื้อหาหน้าจอ'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Guardian Eye · MVP 1.0.0',
            style: TextStyle(color: Colors.white38),
          ),
        ),
      ],
    );
  }
}
