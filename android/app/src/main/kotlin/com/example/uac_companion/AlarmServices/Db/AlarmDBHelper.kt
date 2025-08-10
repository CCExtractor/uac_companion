package com.ccextractor.uac_companion.data

import android.content.Context
import android.content.ContentValues
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log
import org.json.JSONObject
import com.ccextractor.uac_companion.data.AlarmDbModel

class AlarmDBHelper(context: Context) : SQLiteOpenHelper(context, "wear_alarms.db", null, 1) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE alarms (
                id INTEGER PRIMARY KEY,
                time TEXT NOT NULL,
                days TEXT NOT NULL,
                is_enabled INTEGER NOT NULL,
                is_one_time INTEGER NOT NULL DEFAULT 1,
                from_watch INTEGER NOT NULL DEFAULT 1,
                is_location_enabled INTEGER NOT NULL DEFAULT 0,
                location TEXT DEFAULT '',
                is_guardian INTEGER NOT NULL DEFAULT 0,
                guardian TEXT DEFAULT '',
                guardian_timer INTEGER NOT NULL DEFAULT 0,
                is_call INTEGER NOT NULL DEFAULT 0
            )
            """.trimIndent()
        )
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS alarms")
        onCreate(db)
    }    
}
