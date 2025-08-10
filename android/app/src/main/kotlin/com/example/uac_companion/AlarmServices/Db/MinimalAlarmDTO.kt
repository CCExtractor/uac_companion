package com.ccextractor.uac_companion.data

import android.database.Cursor

data class MinimalAlarmDTO(
    val id: Int,
    val time: String,
    val days: String,
    val isEnabled: Boolean,
    val isOneTime: Int,
    val fromWatch: Boolean,
    val isLocationEnabled: Boolean,
    val location: String,
    val isGuardian: Boolean,
    val guardian: String,
    val guardianTimer: Int,
    val isCall: Boolean
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
                isLocationEnabled = cursor.getInt(cursor.getColumnIndexOrThrow("is_location_enabled")) == 1,
                location = cursor.getString(cursor.getColumnIndexOrThrow("location")),
                isGuardian = cursor.getInt(cursor.getColumnIndexOrThrow("is_guardian")) == 1,
                guardian = cursor.getString(cursor.getColumnIndexOrThrow("guardian")),
                guardianTimer = cursor.getInt(cursor.getColumnIndexOrThrow("guardian_timer")),
                isCall = cursor.getInt(cursor.getColumnIndexOrThrow("is_call")) == 1,
            )
        }
    }
}