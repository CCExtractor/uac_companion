package com.ccextractor.uac_companion

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.ccextractor.uac_companion.AlarmUtils.getNextValidTime
import com.ccextractor.uac_companion.data.Alarm
import java.util.*

object AlarmScheduler {
    final val TAG = "AlarmScheduler"
    // * Call this to schedule the next alarm based on the current alarms from DB
    fun scheduleNextAlarm(context: Context) {
        val alarms = AlarmUtils.getAllAlarmsFromDb(context).filter { it.isEnabled == 1 }
        val upcomingAlarm = AlarmUtils.getNextUpcomingAlarm(alarms)
        if (upcomingAlarm != null) {
            scheduleAlarm(context, upcomingAlarm)
            Log.d(TAG, "scheduleNextAlarm: ${upcomingAlarm.id} at ${upcomingAlarm.time}")
        } else {
            Log.d(TAG, "No upcoming alarms to schedule.")
        }
    }

    // * Actually schedules alarms based on the next valid time
    private fun scheduleAlarm(context: Context, alarm: Alarm) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = getNextValidTime(alarm) ?: return

        val requestCode = alarm.id * 10

        cancelExistingAlarmsFromId(context, alarm)
        val pendingIntent = createAlarmPendingIntent(context, alarm.id, requestCode, alarm)
        setExactAlarmFun(alarmManager, calendar.timeInMillis, pendingIntent)
    }

    private fun cancelExistingAlarmsFromId(context: Context, alarm: Alarm) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val reqCode = alarm.id * 10
        Log.d(TAG, "cancelExistingAlarmsFromId: ID=${alarm.id}, RequestCode=$reqCode")
        val pendingIntent = createAlarmPendingIntent(context, alarm.id, reqCode, alarm)
        alarmManager.cancel(pendingIntent)
    }

    private fun createAlarmPendingIntent(
            context: Context,
            alarmId: Int,
            requestCode: Int,
            alarm: Alarm
    ): PendingIntent {
        val intent =
                Intent(context, AlarmBroadcastReceiver::class.java).apply {
                    action = "com.uac.wearcompanion.ALARM_TRIGGERED_$alarmId"
                    putExtra("alarmId", alarmId)
                    putExtra("days", alarm.days.joinToString(","))
                }
        return PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun cancelAlarm(context: Context, id: Int) {
        val allAlarms = AlarmUtils.getAllAlarmsFromDb(context)
        val alarm = allAlarms.find { it.id == id }
        if (alarm != null) {
            cancelExistingAlarmsFromId(context, alarm)
        } else {
            Log.e(TAG, "No alarm found with ID=$id to cancel")
        }
    }

    private fun setExactAlarmFun(
            alarmManager: AlarmManager,
            time: Long,
            pendingIntent: PendingIntent
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, time, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, time, pendingIntent)
            Log.d(TAG, "Set exact alarm with `setExact`")
        }
    }
}