// package com.ccextractor.uac_companion.communication.data

// import android.content.Context
// import android.database.sqlite.SQLiteDatabase
// import android.database.sqlite.SQLiteOpenHelper
// import android.util.Log

// class CommunicationAlarmDbHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

//     companion object {
//         private const val DATABASE_NAME = "uac_alarms.db"
//         private const val DATABASE_VERSION = 1
//         const val TABLE_ALARMS = "alarms"
//         const val COLUMN_ID = "id"
//         const val COLUMN_TIME = "time"
//         const val COLUMN_DAYS = "days"
//         const val COLUMN_IS_ENABLED = "is_enabled"
//         const val COLUMN_IS_ONE_TIME = "is_one_time"
//         const val COLUMN_FROM_WATCH = "from_watch"
//         const val COLUMN_IS_LOCATION_ENABLED = "is_location_enabled"
//         const val COLUMN_LOCATION = "location"
//         const val COLUMN_IS_GUARDIAN = "is_guardian"
//         const val COLUMN_GUARDIAN = "guardian"
//         const val COLUMN_GUARDIAN_TIMER = "guardian_timer"
//         const val COLUMN_IS_CALL = "is_call"

//         // SQL statement to create the alarms table
//         private const val SQL_CREATE_ENTRIES =
//             "CREATE TABLE $TABLE_ALARMS (" +
//             "$COLUMN_ID INTEGER PRIMARY KEY," + // Assuming ID is unique and serves as PK
//             "$COLUMN_TIME TEXT," +
//             "$COLUMN_DAYS TEXT," + // Store List<Int> as TEXT (comma-separated string)
//             "$COLUMN_IS_ENABLED INTEGER," + // INTEGER for boolean (0/1)
//             "$COLUMN_IS_ONE_TIME INTEGER," +
//             "$COLUMN_FROM_WATCH INTEGER," +
//             "$COLUMN_IS_LOCATION_ENABLED INTEGER," +
//             "$COLUMN_LOCATION TEXT," +
//             "$COLUMN_IS_GUARDIAN INTEGER," +
//             "$COLUMN_GUARDIAN TEXT," +
//             "$COLUMN_GUARDIAN_TIMER INTEGER," +
//             "$COLUMN_IS_CALL INTEGER)"
//     }

//     override fun onCreate(db: SQLiteDatabase) {
//         db.execSQL(SQL_CREATE_ENTRIES)
//         Log.d("AlarmDbHelper", "Alarms table created.")
//     }

//     override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
//         db.execSQL("DROP TABLE IF EXISTS $TABLE_ALARMS")
//         onCreate(db)
//         Log.d("AlarmDbHelper", "Alarms table upgraded. Dropped and recreated.")
//     }
// }