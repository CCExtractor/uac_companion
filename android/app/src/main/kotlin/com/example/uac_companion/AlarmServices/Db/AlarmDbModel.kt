package com.ccextractor.uac_companion.data

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

data class Alarm(
    val id: Int,
    val time: String,
    val days: List<Int>,
    val isEnabled: Int,
    val isOneTime: Int,
    val fromWatch: Boolean,
    // val phoneId: String?,
    val watchId: Int,

    // Screen Activity
    val isActivityEnabled: Boolean = false,
    val activityInterval: Int = 0,
    val activityConditionType: Int = 0,

    // Guardian Angel
    val isGuardian: Boolean = false,
    val guardian: String = "",
    val guardianTimer: Int = 0,
    val isCall: Boolean = false,

    // Weather Condition
    val isWeatherEnabled: Boolean = false,
    val weatherConditionType: Int = 0,
    val weatherTypes: List<Int> = emptyList(),

    // Location Condition
    val isLocationEnabled: Boolean = false,
    val location: String = "",
    val locationConditionType: Int = 0
)

class AlarmDbModel(context: Context) : SQLiteOpenHelper(
    context,
    context.getDatabasePath("wear_alarms.db").absolutePath,
    null,
    1
) {
    override fun onCreate(db: SQLiteDatabase) {}
    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
}
