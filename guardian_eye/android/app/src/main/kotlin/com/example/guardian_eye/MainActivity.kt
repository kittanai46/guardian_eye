package com.example.guardian_eye

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var screenshotCallback: Activity.ScreenCaptureCallback? = null
    private var captureCallbacksRegistered = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStatus" -> result.success(status())
                "getHistory" -> result.success(MonitorStore.events(this))
                "startMonitoring" -> {
                    requestNotificationPermissionIfNeeded()
                    MonitorCoordinator.start(this)
                    registerCaptureCallbacks()
                    result.success(null)
                }
                "stopMonitoring" -> {
                    unregisterCaptureCallbacks()
                    MonitorCoordinator.stop(this)
                    result.success(null)
                }
                "runQuickCheck" -> {
                    requestNotificationPermissionIfNeeded()
                    MonitorCoordinator.start(this, quickCheck = true)
                    registerCaptureCallbacks()
                    result.success(null)
                }
                "setProtectionEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    MonitorStore.setProtectionEnabled(this, enabled)
                    applyScreenProtection()
                    result.success(null)
                }
                "clearHistory" -> {
                    MonitorStore.clearEvents(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                MonitorStore.eventListener = { event -> runOnUiThread { events.success(event) } }
            }

            override fun onCancel(arguments: Any?) {
                MonitorStore.eventListener = null
            }
        })
    }

    override fun onStart() {
        super.onStart()
        applyScreenProtection()
        registerCaptureCallbacks()
    }

    override fun onStop() {
        unregisterCaptureCallbacks()
        super.onStop()
    }

    private fun status(): Map<String, Any> = mapOf(
        "isMonitoring" to MonitorStore.isMonitoring(this),
        "protectionEnabled" to MonitorStore.isProtectionEnabled(this),
        "isBeingRecorded" to MonitorStore.isBeingRecorded(this),
        "platformName" to "Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})",
        "supportsScreenshotDetection" to (Build.VERSION.SDK_INT >= 34),
        "supportsRecordingDetection" to (Build.VERSION.SDK_INT >= 35),
    )

    private fun applyScreenProtection() {
        if (MonitorStore.isProtectionEnabled(this)) window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        else window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    private fun registerCaptureCallbacks() {
        if (captureCallbacksRegistered || !MonitorStore.isMonitoring(this)) return
        if (Build.VERSION.SDK_INT >= 34) {
            screenshotCallback = Activity.ScreenCaptureCallback {
                MonitorStore.addEvent(this, "screenshot", "high", "ตรวจพบการจับภาพหน้าจอ", "มีความพยายามจับภาพหน้าต่าง Guardian Eye")
            }.also { registerScreenCaptureCallback(mainExecutor, it) }
        }
        captureCallbacksRegistered = true
    }

    private fun unregisterCaptureCallbacks() {
        if (!captureCallbacksRegistered) return
        if (Build.VERSION.SDK_INT >= 34) screenshotCallback?.let(::unregisterScreenCaptureCallback)
        screenshotCallback = null
        captureCallbacksRegistered = false
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_PERMISSION_REQUEST)
        }
    }

    companion object {
        private const val METHOD_CHANNEL = "guardian_eye/monitor"
        private const val EVENT_CHANNEL = "guardian_eye/events"
        private const val NOTIFICATION_PERMISSION_REQUEST = 4102
    }
}
