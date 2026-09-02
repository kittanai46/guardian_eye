package com.example.guardian_eye

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MonitorToggleReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_STOP -> MonitorCoordinator.stop(context)
            else -> MonitorCoordinator.toggle(context)
        }
    }

    companion object {
        const val ACTION_TOGGLE = "com.example.guardian_eye.action.TOGGLE_MONITOR"
        const val ACTION_STOP = "com.example.guardian_eye.action.STOP_MONITOR"
    }
}
