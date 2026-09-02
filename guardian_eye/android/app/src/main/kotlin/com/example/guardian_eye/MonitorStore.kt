package com.example.guardian_eye

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

object MonitorStore {
    private const val PREFS = "guardian_eye_monitor"
    private const val KEY_MONITORING = "is_monitoring"
    private const val KEY_PROTECTION = "protection_enabled"
    private const val KEY_RECORDING = "is_being_recorded"
    private const val KEY_EVENTS = "security_events"
    private const val MAX_EVENTS = 200

    var eventListener: ((Map<String, Any>) -> Unit)? = null

    fun isMonitoring(context: Context): Boolean = prefs(context).getBoolean(KEY_MONITORING, false)

    fun setMonitoring(context: Context, enabled: Boolean) {
        prefs(context).edit().putBoolean(KEY_MONITORING, enabled).apply()
    }

    fun isProtectionEnabled(context: Context): Boolean = prefs(context).getBoolean(KEY_PROTECTION, true)

    fun setProtectionEnabled(context: Context, enabled: Boolean) {
        prefs(context).edit().putBoolean(KEY_PROTECTION, enabled).apply()
    }

    fun isBeingRecorded(context: Context): Boolean = prefs(context).getBoolean(KEY_RECORDING, false)

    fun setBeingRecorded(context: Context, recording: Boolean) {
        prefs(context).edit().putBoolean(KEY_RECORDING, recording).apply()
    }

    @Synchronized
    fun addEvent(context: Context, type: String, severity: String, title: String, description: String) {
        val event = linkedMapOf<String, Any>(
            "id" to "${System.currentTimeMillis()}-$type",
            "type" to type,
            "severity" to severity,
            "occurredAt" to isoTimestamp(),
            "title" to title,
            "description" to description,
        )
        val existing = JSONArray(prefs(context).getString(KEY_EVENTS, "[]"))
        val updated = JSONArray().put(JSONObject(event))
        for (index in 0 until minOf(existing.length(), MAX_EVENTS - 1)) {
            updated.put(existing.getJSONObject(index))
        }
        prefs(context).edit().putString(KEY_EVENTS, updated.toString()).apply()
        eventListener?.invoke(event)
    }

    @Synchronized
    fun events(context: Context): List<Map<String, Any>> {
        val array = JSONArray(prefs(context).getString(KEY_EVENTS, "[]"))
        return (0 until array.length()).map { index ->
            val item = array.getJSONObject(index)
            linkedMapOf(
                "id" to item.optString("id"),
                "type" to item.optString("type"),
                "severity" to item.optString("severity"),
                "occurredAt" to item.optString("occurredAt"),
                "title" to item.optString("title"),
                "description" to item.optString("description"),
            )
        }
    }

    fun clearEvents(context: Context) {
        prefs(context).edit().remove(KEY_EVENTS).apply()
    }

    private fun prefs(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun isoTimestamp(): String {
        val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
        formatter.timeZone = TimeZone.getTimeZone("UTC")
        return formatter.format(Date())
    }
}
