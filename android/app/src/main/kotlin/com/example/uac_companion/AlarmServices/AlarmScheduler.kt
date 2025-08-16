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
            Log.d(TAG, "scheduleNextAlarm: ${upcomingAlarm.watchId} at ${upcomingAlarm.time}")
        } else {
            Log.d(TAG, "No upcoming alarms to schedule.")
        }
    }

    // * Actually schedules alarms based on the next valid time
    private fun scheduleAlarm(context: Context, alarm: Alarm) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = getNextValidTime(alarm) ?: return

        // val requestCode = alarm.watchId * 10
        val requestCode = alarm.watchId % 32767

        cancelExistingAlarmsFromId(context, alarm)
        // val pendingIntent = createAlarmPendingIntent(context, alarm.id, requestCode, alarm)
        val pendingIntent = createAlarmPendingIntent(context, alarm.watchId, requestCode, alarm)
        setExactAlarmFun(alarmManager, calendar.timeInMillis, pendingIntent)
    }

    private fun cancelExistingAlarmsFromId(context: Context, alarm: Alarm) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        // val reqCode = alarm.watchId * 10
        val reqCode = alarm.watchId % 32767
        Log.d(TAG, "cancelExistingAlarmsFromId: watchId=${alarm.watchId}, RequestCode=$reqCode")
        // val pendingIntent = createAlarmPendingIntent(context, alarm.id, reqCode, alarm)
        val pendingIntent = createAlarmPendingIntent(context, alarm.watchId, reqCode, alarm)
        alarmManager.cancel(pendingIntent)
    }

    private fun createAlarmPendingIntent(
            context: Context,
            // alarmId: Int,
            watchId: Int,
            requestCode: Int,
            alarm: Alarm
    ): PendingIntent {
        val intent =
                Intent(context, AlarmBroadcastReceiver::class.java).apply {
                    action = "com.uac.wearcompanion.ALARM_TRIGGERED_$watchId"
                    putExtra("watchId", alarm.watchId)
                    putExtra("alarmId", alarm.id)
                    putExtra("days", alarm.days.joinToString(","))
                }
                Log.d("createAlarmPendingIntent", "${alarm.watchId} : ${alarm.id} : ${alarm.days.joinToString(",")}")
        return PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun cancelAlarm(context: Context, watchId: Int) {
        val allAlarms = AlarmUtils.getAllAlarmsFromDb(context)
        // val alarm = allAlarms.find { it.id == id }
        // if (alarm != null) {
        //     cancelExistingAlarmsFromId(context, alarm)
        // } else {
        //     Log.e(TAG, "No alarm found with ID=$id to cancel")
        // }
        val alarm = allAlarms.find { it.watchId == watchId }
        if (alarm != null){
            cancelExistingAlarmsFromId(context, alarm)
        } else {
            Log.e(TAG, "No alarm found with ID=$watchId to cancel")
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