package com.example.guardian_eye

import android.content.Context
import android.content.Intent
import android.os.Build

object MonitorCoordinator {
    fun start(context: Context, quickCheck: Boolean = false) {
        val wasMonitoring = MonitorStore.isMonitoring(context)
        MonitorStore.setMonitoring(context, true)
        if (!wasMonitoring) {
            MonitorStore.addEvent(context, "monitorStarted", "info", "เริ่มการตรวจสอบเบื้องหลัง", "Guardian Eye พร้อมตรวจจับเหตุการณ์ที่ระบบอนุญาต")
        }
        if (quickCheck) {
            MonitorStore.addEvent(context, "quickCheck", "info", "ตรวจสอบด่วนสำเร็จ", capabilitySummary())
        }
        val intent = Intent(context, GuardianMonitorService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) context.startForegroundService(intent) else context.startService(intent)
        GuardianEyeWidget.updateAll(context)
    }

    fun stop(context: Context) {
        if (MonitorStore.isMonitoring(context)) {
            MonitorStore.addEvent(context, "monitorStopped", "info", "หยุดการตรวจสอบ", "ผู้ใช้หยุด Background Monitor")
        }
        MonitorStore.setMonitoring(context, false)
        MonitorStore.setBeingRecorded(context, false)
        context.stopService(Intent(context, GuardianMonitorService::class.java))
        GuardianEyeWidget.updateAll(context)
    }

    fun toggle(context: Context) {
        if (MonitorStore.isMonitoring(context)) stop(context) else start(context, quickCheck = true)
    }

    private fun capabilitySummary(): String = when {
        Build.VERSION.SDK_INT >= 35 -> "พร้อมตรวจ Screenshot และสถานะ Screen Recording ของแอป"
        Build.VERSION.SDK_INT >= 34 -> "พร้อมตรวจ Screenshot; การตรวจ Recording ต้องใช้ Android 15+"
        else -> "เปิดการป้องกันพื้นฐาน; การตรวจจับเต็มรูปแบบต้องใช้ Android 14+"
    }
}
