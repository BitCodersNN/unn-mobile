// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.os.Bundle
import ru.bitcodersnn.unnstudenthub.R

enum class ScheduleWidgetTheme(val label: Int) {
    SYSTEM(R.string.schedule_widget_theme_system),
    LIGHT(R.string.schedule_widget_theme_light),
    DARK(R.string.schedule_widget_theme_dark),
}

enum class ScheduleWidgetTextSize(val label: Int, val scale: Float) {
    SMALL(R.string.schedule_widget_text_small, 0.9f),
    NORMAL(R.string.schedule_widget_text_normal, 1f),
    LARGE(R.string.schedule_widget_text_large, 1.15f),
}

data class ScheduleWidgetSettings(
    val transparency: Int = 0,
    val theme: ScheduleWidgetTheme = ScheduleWidgetTheme.SYSTEM,
    val textSize: ScheduleWidgetTextSize = ScheduleWidgetTextSize.NORMAL,
    val maxLessons: Int = 0,
    val showLocation: Boolean = true,
    val showLecturer: Boolean = false,
) {
    val backgroundAlpha: Int get() = ((100 - transparency.coerceIn(0, 100)) * 255 + 50) / 100

    fun toBundle(): Bundle = Bundle().apply {
        putInt(TRANSPARENCY, transparency)
        putString(THEME, theme.name)
        putString(TEXT_SIZE, textSize.name)
        putInt(MAX_LESSONS, maxLessons)
        putBoolean(SHOW_LOCATION, showLocation)
        putBoolean(SHOW_LECTURER, showLecturer)
    }

    companion object {
        const val TRANSPARENCY = "transparency"
        const val THEME = "theme"
        const val TEXT_SIZE = "text_size"
        const val MAX_LESSONS = "max_lessons"
        const val SHOW_LOCATION = "show_location"
        const val SHOW_LECTURER = "show_lecturer"
        val keys = listOf(TRANSPARENCY, THEME, TEXT_SIZE, MAX_LESSONS, SHOW_LOCATION, SHOW_LECTURER)

        fun fromBundle(bundle: Bundle): ScheduleWidgetSettings = ScheduleWidgetSettings(
            transparency = bundle.getInt(TRANSPARENCY, 0).coerceIn(0, 100),
            theme = ScheduleWidgetTheme.entries.firstOrNull { it.name == bundle.getString(THEME) }
                ?: ScheduleWidgetTheme.SYSTEM,
            textSize = ScheduleWidgetTextSize.entries.firstOrNull { it.name == bundle.getString(TEXT_SIZE) }
                ?: ScheduleWidgetTextSize.NORMAL,
            maxLessons = bundle.getInt(MAX_LESSONS, 0).coerceIn(0, 6),
            showLocation = bundle.getBoolean(SHOW_LOCATION, true),
            showLecturer = bundle.getBoolean(SHOW_LECTURER, false),
        )
    }
}
