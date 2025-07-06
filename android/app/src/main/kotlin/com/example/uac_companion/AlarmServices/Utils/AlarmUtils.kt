package com.ccextractor.uac_companion

import com.ccextractor.uac_companion.data.Alarm
import com.ccextractor.uac_companion.data.AlarmDbModel
import java.util.Calendar
import android.content.Context
import android.util.Log

object AlarmUtils {
    fun getNextValidTime(alarm: Alarm): Calendar? {
        val (hour, minute) = parseTime(alarm.time) ?: return null
        val now = Calendar.getInstance()
        var soonest: Calendar? = null

        if (alarm.days.isEmpty()) {
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
            val enabled = cursor.getInt(cursor.getColumnIndexOrThrow("enabled")) == 1
    
            val days = daysRaw.split(",").mapNotNull { it.trim().toIntOrNull() }
    
            alarms.add(Alarm(id, time, days, enabled))
        }
    
        cursor.close()
        db.close()
        Log.d("UAC_Comp-AlarmUtils", "Fetched alarms from DB: $alarms")
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

    //* Converts the time string "HH:mm" to a Pair of Ints (hour, minute) - "07:30" → Pair(7, 30)
    private fun parseTime(time: String): Pair<Int, Int>? {
        return try {
            val parts = time.split(":").map { it.toInt() }
            if (parts.size == 2) Pair(parts[0], parts[1]) else null
        } catch (e: Exception) {
            null
        }
    }
}