package com.ccextractor.uac_companion.data

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class AlarmDBHelper(context: Context) : SQLiteOpenHelper(context, "wear_alarms.db", null, 2) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE alarms (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                unique_sync_id TEXT NOT NULL UNIQUE,
                time TEXT NOT NULL,
                days TEXT NOT NULL,
                is_enabled INTEGER NOT NULL,
                is_one_time INTEGER NOT NULL DEFAULT 1,
                from_watch INTEGER NOT NULL DEFAULT 1,

                -- Screen Activity
                is_activity_enabled INTEGER NOT NULL DEFAULT 0,
                activity_interval INTEGER NOT NULL DEFAULT 0,
                activity_condition_type INTEGER NOT NULL DEFAULT 0,

                -- Guardian Angel
                is_guardian INTEGER NOT NULL DEFAULT 0,
                guardian TEXT DEFAULT '',
                guardian_timer INTEGER NOT NULL DEFAULT 0,
                is_call INTEGER NOT NULL DEFAULT 0,

                -- Weather Condition
                is_weather_enabled INTEGER NOT NULL DEFAULT 0,
                weather_condition_type INTEGER NOT NULL DEFAULT 0,
                weather_types TEXT DEFAULT '',

                -- Location Condition
                is_location_enabled INTEGER NOT NULL DEFAULT 0,
                location TEXT DEFAULT '',
                location_condition_type INTEGER NOT NULL DEFAULT 0,

                -- Snooze
                snooze_duration INTEGER NOT NULL DEFAULT 5
            )
            """.trimIndent()
        )
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        if (oldVersion < 2) {
             db.execSQL("ALTER TABLE alarms ADD COLUMN snooze_duration INTEGER NOT NULL DEFAULT 5")
        }
    }
}