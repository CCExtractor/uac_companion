package com.ccextractor.uac_companion

import android.content.Context
import android.util.Log
import com.ccextractor.uac_companion.data.Alarm
import com.ccextractor.uac_companion.data.AlarmDbModel
import java.util.Calendar

object AlarmUtils {
    const val TAG = "AlarmUtils"
    fun getNextValidTime(alarm: Alarm): Calendar? {
        val (hour, minute) = parseTime(alarm.time) ?: return null
        val now = Calendar.getInstance()
        var soonest: Calendar? = null

            if (alarm.isOneTime == 1) {
            return Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                if (before(now)) add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        for (day in alarm.days) {
            val cal =
                    Calendar.getInstance().apply {
                        set(Calendar.HOUR_OF_DAY, hour)
                        set(Calendar.MINUTE, minute)
                        set(Calendar.SECOND, 0)
                        set(Calendar.MILLISECOND, 0)

                        val today = get(Calendar.DAY_OF_WEEK)
                        val diff = (day + 1 - today + 7) % 7
                        add(Calendar.DAY_OF_YEAR, if (diff == 0 && before(now)) 7 else diff)
                    }

            if (soonest == null || cal.before(soonest)) {
                soonest = cal
            }
        }

        return soonest
    }

    fun getAllAlarmsFromDb(context: Context): List<Alarm> {
        val db = AlarmDbModel(context).readableDatabase
        val cursor = db.rawQuery("SELECT * FROM alarms", null)
        val alarms = mutableListOf<Alarm>()

        while (cursor.moveToNext()) {
            val id = cursor.getInt(cursor.getColumnIndexOrThrow("id"))
            val time = cursor.getString(cursor.getColumnIndexOrThrow("time"))
            val daysRaw = cursor.getString(cursor.getColumnIndexOrThrow("days"))
            val isEnabled = cursor.getInt(cursor.getColumnIndexOrThrow("is_enabled"))
            val isOneTime = cursor.getInt(cursor.getColumnIndexOrThrow("is_one_time"))
            val fromWatch = cursor.getInt(cursor.getColumnIndexOrThrow("from_watch")) == 1
            val uniqueSyncId = cursor.getString(cursor.getColumnIndexOrThrow("unique_sync_id"))
            
            val isActivityEnabled = cursor.getInt(cursor.getColumnIndex("is_activity_enabled")) == 1
            val activityInterval = cursor.getInt(cursor.getColumnIndex("activity_interval"))
            val activityConditionType = cursor.getInt(cursor.getColumnIndex("activity_condition_type"))
            
            val isGuardian = cursor.getInt(cursor.getColumnIndexOrThrow("is_guardian")) == 1
            val guardian = cursor.getString(cursor.getColumnIndexOrThrow("guardian")) ?: ""
            val guardianTimer = cursor.getInt(cursor.getColumnIndex("guardian_timer"))
            val isCall = cursor.getInt(cursor.getColumnIndexOrThrow("is_call")) == 1
            
            val isWeatherEnabled = cursor.getInt(cursor.getColumnIndex("is_weather_enabled")) == 1
            val weatherConditionType = cursor.getInt(cursor.getColumnIndex("weather_condition_type"))
            val weatherTypesRaw = cursor.getString(cursor.getColumnIndex("weather_types")) ?: ""
            val weatherTypes = weatherTypesRaw.split(",").mapNotNull { it.trim().toIntOrNull() }
            
            val isLocationEnabled =
            cursor.getInt(cursor.getColumnIndexOrThrow("is_location_enabled")) == 1
            val location = cursor.getString(cursor.getColumnIndexOrThrow("location")) ?: ""
            val locationConditionType = cursor.getInt(cursor.getColumnIndex("location_condition_type"))
            val days = daysRaw.split(",").mapNotNull { it.trim().toIntOrNull() }

            val snoozeDurationIndex = cursor.getColumnIndex("snooze_duration")
            val snoozeDuration = if (snoozeDurationIndex != -1) cursor.getInt(snoozeDurationIndex) else 5

            alarms.add(
                    Alarm(
                            id,
                            time,
                            days,
                            isEnabled,
                            isOneTime,
                            fromWatch,
                            uniqueSyncId,

                            isActivityEnabled,
                            activityInterval,
                            activityConditionType,

                            isGuardian,
                            guardian,
                            guardianTimer,
                            isCall,

                            isWeatherEnabled,
                            weatherConditionType,
                            weatherTypes,

                            isLocationEnabled,
                            location,
                            locationConditionType,

                            snoozeDuration
                    )
            )
        }

        cursor.close()
        db.close()
        Log.d(TAG, "Fetched alarms from DB: $alarms")
        return alarms
    }

    fun getNextUpcomingAlarm(alarms: List<Alarm>): Alarm? {
        return alarms
                .mapNotNull { alarm ->
                    val nextTime = getNextValidTime(alarm)
                    if (nextTime != null) Pair(alarm, nextTime.timeInMillis) else null
                }
                .minByOrNull { it.second }
                ?.first
    }

    private fun parseTime(time: String): Pair<Int, Int>? {
        return try {
            val parts = time.split(":").map { it.toInt() }
            if (parts.size == 2) Pair(parts[0], parts[1]) else null
        } catch (e: Exception) {
            null
        }
    }
}