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
    //* Call this to schedule the next alarm based on the current alarms form DB
    fun scheduleNextAlarm(context: Context) {
        val alarms = AlarmUtils.getAllAlarmsFromDb(context).filter { it.enabled }
        val upcomingAlarm = AlarmUtils.getNextUpcomingAlarm(alarms)
    
        if (upcomingAlarm != null) {
            scheduleAlarm(context, upcomingAlarm)
        } else {
            Log.d("UAC_Comp-AlarmScheduler", "No upcoming alarms to schedule.")
        }
    }

    //* Actually schedules alarms based on the next valid time
    private fun scheduleAlarm(context: Context, alarm: Alarm) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val calendar = getNextValidTime(alarm) ?: return
    
        val requestCode = alarm.id * 10
    
        cancelExistingAlarmsFromId(context, alarm)
    
        val pendingIntent = createAlarmPendingIntent(context, alarm.id, requestCode, alarm)
        setExactAlarmFun(alarmManager, calendar.timeInMillis, pendingIntent)
    
        Log.d("UAC_Comp-AlarmScheduler", "Scheduled alarm ID=${alarm.id} for ${calendar.time}")
    }
    
    private fun cancelExistingAlarmsFromId(context: Context, alarm: Alarm) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (i in 0..7) {
            val reqCode = alarm.id * 10 + i
            val pendingIntent = createAlarmPendingIntent(context, alarm.id, reqCode, alarm)
            alarmManager.cancel(pendingIntent)
        }
    }
    
    private fun createAlarmPendingIntent(
        context: Context,
        alarmId: Int,
        requestCode: Int,
        alarm: Alarm
    ): PendingIntent {
        val intent = Intent(context, AlarmBroadcastReceiver::class.java).apply {
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
        Log.d("UAC_Comp-AlarmScheduler", "Cancel requested for ID=$id")
        // val alarm = getAllAlarmsFromDb(context).find { it.id == id }
        val allAlarms = AlarmUtils.getAllAlarmsFromDb(context).filter { it.enabled }
        val alarm = allAlarms.find { it.id == id }
        if (alarm != null) {
            cancelExistingAlarmsFromId(context, alarm)
        } else {
            Log.e("UAC_Comp-AlarmScheduler", "No alarm found with ID=$id to cancel")
        }
    }

    //! need to check this setExact might cause the UAC error in some devices
    private fun setExactAlarmFun(alarmManager: AlarmManager, time: Long, pendingIntent: PendingIntent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, time, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, time, pendingIntent)
        }
    }
}