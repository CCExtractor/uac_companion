// package com.ccextractor.uac_companion.communication.data

// import android.content.ContentValues
// import android.content.Context
// import android.database.Cursor
// import android.database.sqlite.SQLiteDatabase
// import android.util.Log
// import com.ccextractor.uac_companion.data.AlarmDbHelper

// class AlarmRepository(context: Context) {
//     private val dbHelper = CommunicationAlarmDbHelper(context)

//     // Converts List<Int> to a comma-separated String for storage
//     private fun daysListToString(days: List<Int>): String {
//         return days.joinToString(",")
//     }

//     // Converts comma-separated String from DB to List<Int>
//     private fun daysStringToList(daysString: String?): List<Int> {
//         return daysString?.split(",")?.mapNotNull { it.trim().toIntOrNull() } ?: emptyList()
//     }

//     // Converts Cursor row to an Alarm object
//     private fun cursorToAlarm(cursor: Cursor): AlarmModelReceived {
//         return AlarmModelReceived(
//             id = cursor.getInt(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_ID)),
//             time = cursor.getString(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_TIME)),
//             days = daysStringToList(cursor.getString(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_DAYS))),
//             isEnabled = cursor.getInt(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_IS_ENABLED)),
//             isOneTime = cursor.getInt(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_IS_ONE_TIME)),
//             fromWatch = cursor.getInt(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_FROM_WATCH)) == 1,
//             isLocationEnabled = cursor.getInt(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_IS_LOCATION_ENABLED)) == 1,
//             location = cursor.getString(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_LOCATION)),
//             isGuardian = cursor.getInt(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_IS_GUARDIAN)) == 1,
//             guardian = cursor.getString(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_GUARDIAN)),
//             guardianTimer = cursor.getInt(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_GUARDIAN_TIMER)),
//             isCall = cursor.getInt(cursor.getColumnIndexOrThrow(CommunicationAlarmDbHelper.COLUMN_IS_CALL)) == 1
//         )
//     }

//     fun insertAlarm(alarm: AlarmModelReceived) {
//         val db = dbHelper.writableDatabase
//         val values = ContentValues().apply {
//             put(CommunicationAlarmDbHelper.COLUMN_ID, alarm.id)
//             put(CommunicationAlarmDbHelper.COLUMN_TIME, alarm.time)
//             put(CommunicationAlarmDbHelper.COLUMN_DAYS, daysListToString(alarm.days))
//             put(CommunicationAlarmDbHelper.COLUMN_IS_ENABLED, alarm.isEnabled)
//             put(CommunicationAlarmDbHelper.COLUMN_IS_ONE_TIME, alarm.isOneTime)
//             put(CommunicationAlarmDbHelper.COLUMN_FROM_WATCH, if (alarm.fromWatch) 1 else 0)
//             put(CommunicationAlarmDbHelper.COLUMN_IS_LOCATION_ENABLED, if (alarm.isLocationEnabled) 1 else 0)
//             put(CommunicationAlarmDbHelper.COLUMN_LOCATION, alarm.location)
//             put(CommunicationAlarmDbHelper.COLUMN_IS_GUARDIAN, if (alarm.isGuardian) 1 else 0)
//             put(CommunicationAlarmDbHelper.COLUMN_GUARDIAN, alarm.guardian)
//             put(CommunicationAlarmDbHelper.COLUMN_GUARDIAN_TIMER, alarm.guardianTimer)
//             put(CommunicationAlarmDbHelper.COLUMN_IS_CALL, if (alarm.isCall) 1 else 0)
//         }
//         // Insert or replace: if ID exists, it updates; otherwise, it inserts
//         val newRowId = db.insertWithOnConflict(
//             CommunicationAlarmDbHelper.TABLE_ALARMS,
//             null,
//             values,
//             SQLiteDatabase.CONFLICT_REPLACE
//         )
//         Log.d("AlarmRepository", "Inserted/Updated alarm with ID: $newRowId")
//         db.close()
//     }

//     fun insertAll(alarms: List<AlarmModelReceived>) {
//         val db = dbHelper.writableDatabase
//         db.beginTransaction() // Start a transaction for efficiency and atomicity
//         try {
//             // Clear existing alarms if it's a full sync
//             db.delete(CommunicationAlarmDbHelper.TABLE_ALARMS, null, null)

//             for (alarm in alarms) {
//                 val values = ContentValues().apply {
//                     put(CommunicationAlarmDbHelper.COLUMN_ID, alarm.id)
//                     put(CommunicationAlarmDbHelper.COLUMN_TIME, alarm.time)
//                     put(CommunicationAlarmDbHelper.COLUMN_DAYS, daysListToString(alarm.days))
//                     put(CommunicationAlarmDbHelper.COLUMN_IS_ENABLED, alarm.isEnabled)
//                     put(CommunicationAlarmDbHelper.COLUMN_IS_ONE_TIME, alarm.isOneTime)
//                     put(CommunicationAlarmDbHelper.COLUMN_FROM_WATCH, if (alarm.fromWatch) 1 else 0)
//                     put(CommunicationAlarmDbHelper.COLUMN_IS_LOCATION_ENABLED, if (alarm.isLocationEnabled) 1 else 0)
//                     put(CommunicationAlarmDbHelper.COLUMN_LOCATION, alarm.location)
//                     put(CommunicationAlarmDbHelper.COLUMN_IS_GUARDIAN, if (alarm.isGuardian) 1 else 0)
//                     put(CommunicationAlarmDbHelper.COLUMN_GUARDIAN, alarm.guardian)
//                     put(CommunicationAlarmDbHelper.COLUMN_GUARDIAN_TIMER, alarm.guardianTimer)
//                     put(CommunicationAlarmDbHelper.COLUMN_IS_CALL, if (alarm.isCall) 1 else 0)
//                 }
//                 db.insertWithOnConflict(CommunicationAlarmDbHelper.TABLE_ALARMS, null, values, SQLiteDatabase.CONFLICT_REPLACE)
//             }
//             db.setTransactionSuccessful() // Commit the transaction
//             Log.d("AlarmRepository", "Successfully inserted/updated ${alarms.size} alarms.")
//         } catch (e: Exception) {
//             Log.e("AlarmRepository", "Error in bulk insertAll", e)
//         } finally {
//             db.endTransaction() // End the transaction
//             db.close()
//         }
//     }

//     fun getAllAlarms(): List<AlarmModelReceived> {
//         val alarms = mutableListOf<AlarmModelReceived>()
//         val db = dbHelper.readableDatabase
//         var cursor: Cursor? = null
//         try {
//             cursor = db.query(
//                 CommunicationAlarmDbHelper.TABLE_ALARMS,
//                 null, // all columns
//                 null, // no WHERE clause
//                 null, // no WHERE arguments
//                 null, // no GROUP BY
//                 null, // no HAVING
//                 null  // no ORDER BY
//             )
//             with(cursor) {
//                 if (this != null && moveToFirst()) {
//                     do {
//                         alarms.add(cursorToAlarm(this))
//                     } while (moveToNext())
//                 }
//             }
//         } catch (e: Exception) {
//             Log.e("AlarmRepository", "Error getting all alarms", e)
//         } finally {
//             cursor?.close()
//             db.close()
//         }
//         return alarms
//     }

//     fun deleteAllAlarms() {
//         val db = dbHelper.writableDatabase
//         db.delete(CommunicationAlarmDbHelper.TABLE_ALARMS, null, null)
//         Log.d("AlarmRepository", "All alarms deleted.")
//         db.close()
//     }

//     // Add other methods (update, delete by ID, get by ID) as needed
// }