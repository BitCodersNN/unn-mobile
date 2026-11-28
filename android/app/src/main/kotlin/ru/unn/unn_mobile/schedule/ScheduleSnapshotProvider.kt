// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedule

import android.content.Context

internal class ScheduleSnapshotProvider(context: Context) {
    private val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    fun readJson(): String? = preferences.getString(DATA_KEY, null)

    fun read(): ScheduleSnapshot? = readJson()?.let { value ->
        runCatching { ScheduleCache.decode(value).snapshot() }.getOrNull()
    }

    fun writeJson(value: String) {
        ScheduleCache.decode(value)
        check(preferences.edit().putString(DATA_KEY, value).remove(PREVIOUS_DATA_KEY).commit())
    }

    private companion object {
        const val PREFERENCES = "schedule_widget"
        const val DATA_KEY = "schedule_cache"
        const val PREVIOUS_DATA_KEY = "data"
    }
}
