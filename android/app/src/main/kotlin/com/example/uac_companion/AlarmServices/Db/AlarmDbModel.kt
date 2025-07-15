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
    val isLocationEnabled: Boolean = false,
    val location: String = "",
    val isGuardian: Boolean = false,
    val guardian: String = "",
    val guardianTimer: Int = 0,
    val isCall: Boolean = false
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