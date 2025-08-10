package com.ccextractor.uac_companion.data

import android.database.Cursor

data class MinimalAlarmDTO(
    val id: Int,
    val time: String,
    val days: String,
    val isEnabled: Boolean,
    val isOneTime: Int,
    val fromWatch: Boolean,

    // Screen Activity
    val isActivityEnabled: Boolean,
    val activityInterval: Int,
    val activityConditionType: Int,

    // Guardian Angel
    val isGuardian: Boolean,
    val guardian: String,
    val guardianTimer: Int,
    val isCall: Boolean,

    // Weather Condition
    val isWeatherEnabled: Boolean,
    val weatherConditionType: Int,
    val weatherTypes: String, // store as comma-separated list

    // Location Condition
    val isLocationEnabled: Boolean,
    val location: String,
    val locationConditionType: Int
) {
    companion object {
        fun fromCursor(cursor: Cursor): MinimalAlarmDTO {
            return MinimalAlarmDTO(
                id = cursor.getInt(cursor.getColumnIndexOrThrow("id")),
                time = cursor.getString(cursor.getColumnIndexOrThrow("time")),
                days = cursor.getString(cursor.getColumnIndexOrThrow("days")),
                isEnabled = cursor.getInt(cursor.getColumnIndexOrThrow("is_enabled")) == 1,
                isOneTime = cursor.getInt(cursor.getColumnIndexOrThrow("is_one_time")),
                fromWatch = cursor.getInt(cursor.getColumnIndexOrThrow("from_watch")) == 1,

                // Screen Activity
                isActivityEnabled = cursor.getInt(cursor.getColumnIndexOrThrow("is_activity_enabled")) == 1,
                activityInterval = cursor.getInt(cursor.getColumnIndexOrThrow("activity_interval")),
                activityConditionType = cursor.getInt(cursor.getColumnIndexOrThrow("activity_condition_type")),

                // Guardian Angel
                isGuardian = cursor.getInt(cursor.getColumnIndexOrThrow("is_guardian")) == 1,
                guardian = cursor.getString(cursor.getColumnIndexOrThrow("guardian")),
                guardianTimer = cursor.getInt(cursor.getColumnIndexOrThrow("guardian_timer")),
                isCall = cursor.getInt(cursor.getColumnIndexOrThrow("is_call")) == 1,

                // Weather Condition
                isWeatherEnabled = cursor.getInt(cursor.getColumnIndexOrThrow("is_weather_enabled")) == 1,
                weatherConditionType = cursor.getInt(cursor.getColumnIndexOrThrow("weather_condition_type")),
                weatherTypes = cursor.getString(cursor.getColumnIndexOrThrow("weather_types")),

                // Location Condition
                isLocationEnabled = cursor.getInt(cursor.getColumnIndexOrThrow("is_location_enabled")) == 1,
                location = cursor.getString(cursor.getColumnIndexOrThrow("location")),
                locationConditionType = cursor.getInt(cursor.getColumnIndexOrThrow("location_condition_type"))
            )
        }
    }
}