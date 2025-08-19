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
            val uniqueSyncId = json.getString("uniqueSyncId")
            val id = json.getString("alarmID").hashCode()
            val time = json.getString("alarmTime")
            val rawDays = json.get("days")
            val days: List<Int> =
                when (rawDays) {
                    is String -> parseDaysFromBinaryString(rawDays)
                    is JSONArray -> List(rawDays.length()) { rawDays.getInt(it) }
                    else -> emptyList()
                }

            val values = ContentValues().apply {
                put("id", id)
                put("time", time)
                put("days", days.joinToString(","))
                put("is_enabled", json.optInt("isEnabled", 1))
                put("is_one_time", json.optInt("isOneTime", if (days.isEmpty()) 1 else 0))
                put("from_watch", 0)
                put("unique_sync_id", uniqueSyncId)

                // Screen Activity
                put("is_activity_enabled", json.optInt("isActivityEnabled", 0))
                put("activity_interval", json.optInt("activityInterval", 0))
                put("activity_condition_type", json.optInt("activityConditionType", 0))

                // Guardian Angel
                put("is_guardian", json.optInt("isGuardian", 0))
                put("guardian", json.optString("guardian", ""))
                put("guardian_timer", json.optInt("guardianTimer", 0))
                put("is_call", json.optInt("isCall", 0))

                // Weather Condition
                put("is_weather_enabled", json.optInt("isWeatherEnabled", 0))
                put("weather_condition_type", json.optInt("weatherConditionType", 0))
                put("weather_types", json.optJSONArray("weatherTypes")?.join(",") ?: "")

                // Location Condition
                put("is_location_enabled", json.optInt("isLocationEnabled", 0))
                put("location", json.optString("location", ""))
                put("location_condition_type", json.optInt("locationConditionType", 0))
            }

            val db = AlarmDbModel(context).writableDatabase
            val rowId = db.insertWithOnConflict("alarms", null, values, SQLiteDatabase.CONFLICT_REPLACE)
            Log.d("AlarmDBService", "Inserted alarm into DB with row ID: $rowId")
            return rowId
        } catch (e: Exception) {
            Log.e("AlarmDBService", "Error inserting alarm: ${e.message}", e)
            return -1
        }
    }

    fun insertAlarm(alarm: MinimalAlarmDTO): Long {
        val db = dbHelper.writableDatabase
        val values = ContentValues().apply {
            put("id", alarm.id)
            put("time", alarm.time)
            put("days", alarm.days)
            put("is_enabled", if (alarm.isEnabled) 1 else 0)
            put("is_one_time", alarm.isOneTime)
            put("from_watch", if (alarm.fromWatch) 1 else 0)
            put("unique_sync_id", alarm.uniqueSyncId)

            // Screen Activity
            put("is_activity_enabled", if (alarm.isActivityEnabled) 1 else 0)
            put("activity_interval", alarm.activityInterval)
            put("activity_condition_type", alarm.activityConditionType)

            // Guardian Angel
            put("is_guardian", if (alarm.isGuardian) 1 else 0)
            put("guardian", alarm.guardian)
            put("guardian_timer", alarm.guardianTimer)
            put("is_call", if (alarm.isCall) 1 else 0)

            // Weather Condition
            put("is_weather_enabled", if (alarm.isWeatherEnabled) 1 else 0)
            put("weather_condition_type", alarm.weatherConditionType)
            // put("weather_types", alarm.weatherTypes.joinToString(","))
            // put("weather_types", alarm.weatherTypes.joinToString(","))
            put("weather_types", alarm.weatherTypes.toList().joinToString(","))


            // Location Condition
            put("is_location_enabled", if (alarm.isLocationEnabled) 1 else 0)
            put("location", alarm.location)
            put("location_condition_type", alarm.locationConditionType)
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
        val values = ContentValues().apply {
            put("time", alarm.time)
            put("days", alarm.days)
            put("is_enabled", if (alarm.isEnabled) 1 else 0)
            put("is_one_time", alarm.isOneTime)
            put("from_watch", if (alarm.fromWatch) 1 else 0)
            put("unique_sync_id", alarm.uniqueSyncId)

            // Screen Activity
            put("is_activity_enabled", if (alarm.isActivityEnabled) 1 else 0)
            put("activity_interval", alarm.activityInterval)
            put("activity_condition_type", alarm.activityConditionType)

            // Guardian Angel
            put("is_guardian", if (alarm.isGuardian) 1 else 0)
            put("guardian", alarm.guardian)
            put("guardian_timer", alarm.guardianTimer)
            put("is_call", if (alarm.isCall) 1 else 0)

            // Weather Condition
            put("is_weather_enabled", if (alarm.isWeatherEnabled) 1 else 0)
            put("weather_condition_type", alarm.weatherConditionType)
            // put("weather_types", alarm.weatherTypes.joinToString(","))
            // put("weather_types", alarm.weatherTypes.joinToString(","))
            put("weather_types", alarm.weatherTypes.toList().joinToString(","))

            // Location Condition
            put("is_location_enabled", if (alarm.isLocationEnabled) 1 else 0)
            put("location", alarm.location)
            put("location_condition_type", alarm.locationConditionType)
        }
        return db.update("alarms", values, "id = ?", arrayOf(alarm.id.toString()))
    }

    //! doubt
    fun deleteAlarm(uniqueSyncId: String): Int {
        val db = dbHelper.writableDatabase
        return db.delete("alarms", "unique_sync_id = ?", arrayOf(uniqueSyncId))
    }
}