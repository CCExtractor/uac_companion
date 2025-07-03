package com.ccextractor.uac_companion

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.ccextractor.uac_companion.data.Alarm
import com.ccextractor.uac_companion.data.AlarmDbModel
import java.text.SimpleDateFormat
import java.util.*
import com.ccextractor.uac_companion.AlarmUtils.getNextValidTime

object AlarmScheduler {
    fun scheduleNextAlarm(context: Context) {
        val alarms = getAllAlarmsFromDb(context).filter { it.enabled }
        val upcoming = getNextAlarmInstance(alarms)

        if (upcoming != null) {
            scheduleAlarm(context, upcoming)
        } else {
            Log.d("AlarmScheduler", "No upcoming alarms to schedule.")
        }
    }

    private fun scheduleAlarm(context: Context, alarm: Alarm) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = getNextValidTime(alarm) ?: return

        val requestCode = alarm.id * 10
        val pi = createAlarmPendingIntent(context, alarm.id, requestCode)

        cancelExistingAlarmsForId(context, alarm.id) // Ensure no duplicates
        setExactAlarmCompat(alarmManager, calendar.timeInMillis, pi)

        Log.d("AlarmScheduler", "Scheduled alarm ID=${alarm.id} for ${calendar.time}")
    }

    fun cancelAlarm(context: Context, id: Int) {
        Log.d("AlarmScheduler", "Cancel requested for ID=$id")
        cancelExistingAlarmsForId(context, id)
    }

    private fun getAllAlarmsFromDb(context: Context): List<Alarm> {
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
        return alarms
    }

    private fun getNextAlarmInstance(alarms: List<Alarm>): Alarm? {
        val now = Calendar.getInstance()
        return alarms
            .mapNotNull { alarm ->
                val nextTime = getNextValidTime(alarm)
                if (nextTime != null) Pair(alarm, nextTime.timeInMillis) else null
            }
            .minByOrNull { it.second }
            ?.first
    }


    private fun cancelExistingAlarmsForId(context: Context, alarmId: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (i in 0..7) {
            val reqCode = alarmId * 10 + i
            val pi = createAlarmPendingIntent(context, alarmId, reqCode)
            alarmManager.cancel(pi)
        }
    }

    private fun createAlarmPendingIntent(context: Context, alarmId: Int, requestCode: Int): PendingIntent {
        val intent = Intent(context, AlarmBroadcastReceiver::class.java).apply {
            action = "com.uac.wearcompanion.ALARM_TRIGGERED_$alarmId"
            putExtra("alarmId", alarmId)
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun setExactAlarmCompat(alarmManager: AlarmManager, time: Long, pi: PendingIntent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, time, pi)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, time, pi)
        }
    }
}
