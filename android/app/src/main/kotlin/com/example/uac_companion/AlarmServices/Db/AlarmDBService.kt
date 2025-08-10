package com.ccextractor.uac_companion.data

import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import com.ccextractor.uac_companion.communication.parseDaysFromBinaryString
import org.json.JSONArray
import org.json.JSONObject

class AlarmDBService(context: Context) {
    private val dbHelper = AlarmDBHelper(context)

    fun insertAlarmFromJson(context: Context, jsonString: String): Long {
        try {
            val json = JSONObject(jsonString)
            val id = json.getString("alarmID").hashCode()
            val time = json.getString("alarmTime")
            // val daysBinary = json.getString("days")
            // val days = daysBinary.mapIndexedNotNull { index, c -> if (c == '1') index else null }
            val rawDays = json.get("days")
            val days: List<Int> =
                    when (rawDays) {
                        is String -> parseDaysFromBinaryString(rawDays)
                        is JSONArray -> List(rawDays.length()) { rawDays.getInt(it) }
                        else -> emptyList()
                    }

            val isOneTime = if (days.isEmpty()) 1 else 0

            val values =
                    ContentValues().apply {
                        put("id", id)
                        put("time", time)
                        put("days", days.joinToString(","))
                        put("is_enabled", json.optInt("isEnabled", 1))
                        put("is_one_time", json.optInt("isOneTime", 1))
                        put("from_watch", 0)
                        put("is_location_enabled", json.optInt("isLocationEnabled", 0))
                        put("location", json.optString("location", ""))
                        put("is_guardian", json.optInt("isGuardian", 0))
                        put("guardian", json.optString("guardian", ""))
                        put("guardian_timer", json.optInt("guardianTimer", 0))
                        put("is_call", json.optInt("isCall", 0))
                    }

            val db = AlarmDbModel(context).writableDatabase
            val rowId =
                    db.insertWithOnConflict("alarms", null, values, SQLiteDatabase.CONFLICT_REPLACE)

            Log.d("AlarmDBService", "Inserted alarm into DB with row ID: $rowId")
            return rowId
        } catch (e: Exception) {
            Log.e("AlarmDBService", "Error inserting alarm: ${e.message}", e)
            return -1
        }
    }

    fun insertAlarm(alarm: MinimalAlarmDTO): Long {
        val db = dbHelper.writableDatabase
        val values =
                ContentValues().apply {
                    put("id", alarm.id)
                    put("time", alarm.time)
                    put("days", alarm.days)
                    put("is_enabled", if (alarm.isEnabled) 1 else 0)
                    put("is_one_time", alarm.isOneTime)
                    put("from_watch", if (alarm.fromWatch) 1 else 0)
                    put("is_location_enabled", if (alarm.isLocationEnabled) 1 else 0)
                    put("location", alarm.location)
                    put("is_guardian", if (alarm.isGuardian) 1 else 0)
                    put("guardian", alarm.guardian)
                    put("guardian_timer", alarm.guardianTimer)
                    put("is_call", if (alarm.isCall) 1 else 0)
                }
        return db.insertWithOnConflict("alarms", null, values, SQLiteDatabase.CONFLICT_REPLACE)
    }

    fun getAllAlarms(): List<MinimalAlarmDTO> {
        val db = dbHelper.readableDatabase
        val cursor: Cursor = db.rawQuery("SELECT * FROM alarms", null)
        val alarms = mutableListOf<MinimalAlarmDTO>()

        if (cursor.moveToFirst()) {
            do {
                alarms.add(MinimalAlarmDTO.fromCursor(cursor))
            } while (cursor.moveToNext())
        }

        cursor.close()
        return alarms
    }

    fun updateAlarm(alarm: MinimalAlarmDTO): Int {
        val db = dbHelper.writableDatabase
        val values =
                ContentValues().apply {
                    put("time", alarm.time)
                    put("days", alarm.days)
                    put("is_enabled", if (alarm.isEnabled) 1 else 0)
                    put("is_one_time", alarm.isOneTime)
                    put("from_watch", if (alarm.fromWatch) 1 else 0)
                    put("is_location_enabled", if (alarm.isLocationEnabled) 1 else 0)
                    put("location", alarm.location)
                    put("is_guardian", if (alarm.isGuardian) 1 else 0)
                    put("guardian", alarm.guardian)
                    put("guardian_timer", alarm.guardianTimer)
                    put("is_call", if (alarm.isCall) 1 else 0)
                }
        return db.update("alarms", values, "id = ?", arrayOf(alarm.id.toString()))
    }

    fun deleteAlarm(id: Int): Int {
        val db = dbHelper.writableDatabase
        return db.delete("alarms", "id = ?", arrayOf(id.toString()))
    }
}