package com.ccextractor.uac_companion

import com.ccextractor.uac_companion.data.Alarm
import java.util.Calendar

object AlarmUtils {
    fun getNextValidTime(alarm: Alarm): Calendar? {
        val (hour, minute) = parseTime(alarm.time) ?: return null
        val now = Calendar.getInstance()
        var soonest: Calendar? = null

        if (alarm.days.isEmpty()) {
            val (hour, minute) = parseTime(alarm.time) ?: return null
            val now = Calendar.getInstance()

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

    private fun parseTime(time: String): Pair<Int, Int>? {
        return try {
            val parts = time.split(":").map { it.toInt() }
            if (parts.size == 2) Pair(parts[0], parts[1]) else null
        } catch (e: Exception) {
            null
        }
    }
}
