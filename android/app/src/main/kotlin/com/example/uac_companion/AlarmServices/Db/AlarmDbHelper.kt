package com.ccextractor.uac_companion.data

import android.content.Context
import android.util.Log

object AlarmDbHelper {
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
                val enabled = cursor.getInt(cursor.getColumnIndexOrThrow("enabled")) == 1

                val days = daysString
                    .split(",")
                    .mapNotNull { it.trim().toIntOrNull() }

                alarms.add(Alarm(id, time, days, enabled))
            } while (cursor.moveToNext())
        }

        cursor.close()
        db.close()
        return alarms
    }
}