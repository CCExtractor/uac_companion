package com.ccextractor.uac_companion.data

import android.content.Context
import android.util.Log

class AlarmDbHelper {
    fun getAllAlarms(context: Context): List<Alarm> {
        val dbHelper = AlarmDbModel(context)
        val db = dbHelper.readableDatabase
        val cursor = db.query("alarms", null, null, null, null, null, null)

        val alarms = mutableListOf<Alarm>()

        if (cursor.moveToFirst()) {
            do {
                val id = cursor.getInt(cursor.getColumnIndexOrThrow("id"))
                val time = cursor.getString(cursor.getColumnIndexOrThrow("time"))
                val daysString = cursor.getString(cursor.getColumnIndexOrThrow("days"))
                val isEnabled = cursor.getInt(cursor.getColumnIndexOrThrow("is_enabled"))
                val isOneTime = cursor.getInt(cursor.getColumnIndexOrThrow("is_one_time"))
                val fromWatch = cursor.getInt(cursor.getColumnIndexOrThrow("from_watch")) == 1
                val isLocationEnabled = cursor.getInt(cursor.getColumnIndexOrThrow("is_location_enabled")) == 1
                val location = cursor.getString(cursor.getColumnIndexOrThrow("location")) ?: ""
                val isGuardian = cursor.getInt(cursor.getColumnIndexOrThrow("is_guardian")) == 1
                val guardian = cursor.getString(cursor.getColumnIndexOrThrow("guardian")) ?: ""
                val guardianTimer = cursor.getInt(cursor.getColumnIndexOrThrow("guardian_timer"))
                val isCall = cursor.getInt(cursor.getColumnIndexOrThrow("is_call")) == 1

                val days = daysString
                    .split(",")
                    .mapNotNull { it.trim().toIntOrNull() }

                alarms.add(Alarm(id, time, days, isEnabled, isOneTime, fromWatch, isLocationEnabled, location, isGuardian, guardian, guardianTimer, isCall))
            } while (cursor.moveToNext())
        }

        cursor.close()
        db.close()
        return alarms
    }
}