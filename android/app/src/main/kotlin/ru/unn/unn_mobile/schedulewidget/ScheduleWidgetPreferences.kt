// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.content.Context
import android.os.Bundle

class ScheduleWidgetPreferences(context: Context) {
    private val preferences = context.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE)

    fun read(widgetId: Int): ScheduleWidgetSettings = ScheduleWidgetSettings.fromBundle(Bundle().apply {
        putInt(ScheduleWidgetSettings.TRANSPARENCY,
            preferences.getInt(key(ScheduleWidgetSettings.TRANSPARENCY, widgetId), 0))
        putString(ScheduleWidgetSettings.THEME,
            preferences.getString(key(ScheduleWidgetSettings.THEME, widgetId), null))
        putString(ScheduleWidgetSettings.TEXT_SIZE,
            preferences.getString(key(ScheduleWidgetSettings.TEXT_SIZE, widgetId), null))
        putInt(ScheduleWidgetSettings.MAX_LESSONS,
            preferences.getInt(key(ScheduleWidgetSettings.MAX_LESSONS, widgetId), 0))
        putBoolean(ScheduleWidgetSettings.SHOW_LOCATION,
            preferences.getBoolean(key(ScheduleWidgetSettings.SHOW_LOCATION, widgetId), true))
        putBoolean(ScheduleWidgetSettings.SHOW_LECTURER,
            preferences.getBoolean(key(ScheduleWidgetSettings.SHOW_LECTURER, widgetId), false))
    })

    fun save(widgetId: Int, settings: ScheduleWidgetSettings) {
        preferences.edit()
            .putInt(key(ScheduleWidgetSettings.TRANSPARENCY, widgetId), settings.transparency)
            .putString(key(ScheduleWidgetSettings.THEME, widgetId), settings.theme.name)
            .putString(key(ScheduleWidgetSettings.TEXT_SIZE, widgetId), settings.textSize.name)
            .putInt(key(ScheduleWidgetSettings.MAX_LESSONS, widgetId), settings.maxLessons)
            .putBoolean(key(ScheduleWidgetSettings.SHOW_LOCATION, widgetId), settings.showLocation)
            .putBoolean(key(ScheduleWidgetSettings.SHOW_LECTURER, widgetId), settings.showLecturer)
            .apply()
    }

    fun remove(widgetIds: IntArray) {
        val editor = preferences.edit()
        widgetIds.forEach { id -> ScheduleWidgetSettings.keys.forEach { editor.remove(key(it, id)) } }
        editor.apply()
    }

    private fun key(name: String, widgetId: Int): String = "${name}_$widgetId"

    private companion object {
        const val FILE_NAME = "schedule_widget_appearance"
    }
}
