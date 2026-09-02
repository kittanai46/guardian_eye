package com.example.guardian_eye

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.view.WindowManager
import java.util.function.Consumer

class GuardianMonitorService : Service() {
    private var recordingCallback: Consumer<Int>? = null

    override fun onCreate() {
        super.onCreate()
        val channel = NotificationChannel(CHANNEL_ID, "Guardian Eye Monitor", NotificationManager.IMPORTANCE_LOW).apply {
            description = "แสดงสถานะเมื่อ Guardian Eye กำลังตรวจสอบเบื้องหลัง"
            setShowBadge(false)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        registerRecordingMonitor()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!MonitorStore.isMonitoring(this)) {
            stopSelf()
            return START_NOT_STICKY
        }
        startForeground(NOTIFICATION_ID, buildNotification())
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= 35) {
            recordingCallback?.let {
                getSystemService(WindowManager::class.java).removeScreenRecordingCallback(it)
            }
        }
        recordingCallback = null
        MonitorStore.setBeingRecorded(this, false)
        super.onDestroy()
    }

    private fun registerRecordingMonitor() {
        if (Build.VERSION.SDK_INT < 35 || recordingCallback != null) return
        val manager = getSystemService(WindowManager::class.java)
        recordingCallback = Consumer<Int> { state ->
            val visible = state == WindowManager.SCREEN_RECORDING_STATE_VISIBLE
            if (visible != MonitorStore.isBeingRecorded(this)) {
                MonitorStore.setBeingRecorded(this, visible)
                MonitorStore.addEvent(
                    this,
                    "screenRecording",
                    if (visible) "high" else "info",
                    if (visible) "ตรวจพบการบันทึกหรือแชร์หน้าจอ" else "การบันทึกหน้าจอสิ้นสุดแล้ว",
                    if (visible) "หน้าต่าง Guardian Eye กำลังปรากฏในการบันทึก" else "หน้าต่างแอปไม่อยู่ในการบันทึกแล้ว",
                )
            }
        }.also { callback ->
            val initialState = manager.addScreenRecordingCallback(mainExecutor, callback)
            callback.accept(initialState)
        }
    }

    private fun buildNotification(): Notification {
        val openPendingIntent = PendingIntent.getActivity(
            this,
            10,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val stopIntent = Intent(this, MonitorToggleReceiver::class.java).apply { action = MonitorToggleReceiver.ACTION_STOP }
        val stopPendingIntent = PendingIntent.getBroadcast(
            this,
            11,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Guardian Eye กำลังทำงาน")
            .setContentText("กำลังเฝ้าระวังเหตุการณ์ความเป็นส่วนตัว")
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .setContentIntent(openPendingIntent)
            .addAction(Notification.Action.Builder(null, "หยุดตรวจสอบ", stopPendingIntent).build())
            .build()
    }

    companion object {
        private const val CHANNEL_ID = "guardian_eye_monitor"
        private const val NOTIFICATION_ID = 4101
    }
}
