package com.example.guardian_eye

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class GuardianEyeWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { id -> update(context, manager, id) }
    }

    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, GuardianEyeWidget::class.java)
            manager.getAppWidgetIds(component).forEach { update(context, manager, it) }
        }

        private fun update(context: Context, manager: AppWidgetManager, id: Int) {
            val active = MonitorStore.isMonitoring(context)
            val views = RemoteViews(context.packageName, R.layout.guardian_eye_widget)
            views.setTextViewText(R.id.widget_status, if (active) "กำลังปกป้อง" else "ยังไม่เริ่มตรวจ")
            views.setTextViewText(R.id.widget_action, if (active) "หยุดตรวจสอบ" else "เริ่มตรวจสอบ")

            val toggleIntent = Intent(context, MonitorToggleReceiver::class.java).apply { action = MonitorToggleReceiver.ACTION_TOGGLE }
            val togglePendingIntent = PendingIntent.getBroadcast(
                context,
                20,
                toggleIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_action, togglePendingIntent)

            val openPendingIntent = PendingIntent.getActivity(
                context,
                21,
                context.packageManager.getLaunchIntentForPackage(context.packageName),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, openPendingIntent)
            manager.updateAppWidget(id, views)
        }
    }
}
