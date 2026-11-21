// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedule

import android.content.Context

internal class ScheduleSnapshotProvider(context: Context) {
    private val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    fun readJson(): String? = preferences.getString(DATA_KEY, null)

    fun read(): ScheduleSnapshot? = readJson()?.let { value ->
        runCatching { ScheduleSnapshot.decode(value) }.getOrNull()
    }

    fun writeJson(value: String) {
        ScheduleSnapshot.decode(value)
        preferences.edit().putString(DATA_KEY, value).apply()
    }

    fun clear() {
        preferences.edit().remove(DATA_KEY).apply()
    }

    private companion object {
        const val PREFERENCES = "schedule_widget"
        const val DATA_KEY = "data"
    }
}
