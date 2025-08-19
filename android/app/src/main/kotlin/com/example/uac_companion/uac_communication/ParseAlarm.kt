package com.ccextractor.uac_companion.communication

import com.ccextractor.uac_companion.data.Alarm
import android.util.Log

fun parseAlarm(map: Map<*, *>): Alarm {

    fun parseStringToIntList(key: String): List<Int> {
        return (map[key] as? String)
            ?.takeIf { it.isNotEmpty() }
            ?.split(",")
            ?.mapNotNull { it.trim().toIntOrNull() }
            ?: emptyList()
    }

    fun fromBoolGetInt(key: String, default: Int): Int {
        return (map[key] as? Number)?.toInt() ?: default
    }

    return Alarm(
        id = (map["id"] as? Number)?.toInt() ?: throw IllegalArgumentException("Missing id"),
        time = map["time"] as? String ?: "",
        days = (map["days"] as? String)
            ?.split(",")
            ?.mapNotNull { it.trim().toIntOrNull() }
            ?: emptyList(),
        // phoneId = map["phone_id"] as? String ?: "",
        uniqueSyncId = map["unique_sync_id"] as? String ?: "",
        isEnabled = (map["is_enabled"] as? Number)?.toInt() ?: 0,
        isOneTime = map["is_one_time"] as? Int ?: 1,
        fromWatch = (map["from_watch"] as? Int ?: 0) == 1,

        isLocationEnabled = (map["is_location_enabled"] as? Int ?: 0) == 1,
        locationConditionType = (map["location_condition_type"] as? Int ?: 0 ),
        location = map["location"] as? String ?: "",

        isWeatherEnabled = (map["is_weather_enabled"] as? Int) == 1,
        weatherConditionType = (map["weather_condition_type"] as? Int ?: 0),
        weatherTypes = parseStringToIntList("weather_types"),

        isActivityEnabled = (map["is_activity_enabled"] as? Int) == 1,
        activityInterval = fromBoolGetInt("activity_interval", 0),
        activityConditionType = fromBoolGetInt("activity_condition_type", 0),

        isGuardian = (map["is_guardian"] as? Int ?: 0) == 1,
        guardian = map["guardian"] as? String ?: "",
        guardianTimer = (map["guardian_timer"] as? Int ?: 0),
        isCall = (map["is_call"] as? Int ?: 0) == 1
    )
}