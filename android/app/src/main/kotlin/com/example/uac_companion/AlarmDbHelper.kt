package com.ccextractor.uac_companion.data

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

data class Alarm(
    val id: Int,
    val time: String,
    val days: List<Int>,
    val enabled: Boolean
)

class AlarmDbHelper(context: Context) : SQLiteOpenHelper(
    context,
    context.getDatabasePath("wear_alarms.db").absolutePath,
    null,
    1
) {
    override fun onCreate(db: SQLiteDatabase) {} // Flutter handles it
    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
}
