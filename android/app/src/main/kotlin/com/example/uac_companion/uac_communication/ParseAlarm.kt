package com.ccextractor.uac_companion.communication

import com.ccextractor.uac_companion.data.Alarm
import android.util.Log

fun parseAlarm(map: Map<*, *>): Alarm {
    return Alarm(
        // id = map["id"] as ? Int, // Flutter int may come as Double
        id = (map["id"] as? Number)?.toInt() ?: throw IllegalArgumentException("Missing id"),
        time = map["time"] as? String ?: "",
        days = (map["days"] as? String)
            ?.split(",")
            ?.mapNotNull { it.trim().toIntOrNull() }
            ?: emptyList(),
        isEnabled = (map["is_enabled"] as? Number)?.toInt() ?: 0,
        isOneTime = map["is_one_time"] as? Int ?: 1,
        fromWatch = (map["from_watch"] as? Int ?: 0) == 1,
        isLocationEnabled = (map["is_location_enabled"] as? Int ?: 0) == 1,
        location = map["location"] as? String ?: "",
        isGuardian = (map["is_guardian"] as? Int ?: 0) == 1,
        guardian = map["guardian"] as? String ?: "",
        guardianTimer = (map["guardian_timer"] as? Int ?: 0),
        isCall = (map["is_call"] as? Int ?: 0) == 1
    )
}