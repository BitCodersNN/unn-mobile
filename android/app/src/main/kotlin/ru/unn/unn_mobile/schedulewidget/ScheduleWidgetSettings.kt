// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.os.Bundle
import ru.bitcodersnn.unnstudenthub.R
import ru.bitcodersnn.unnstudenthub.schedule.ScheduleAppearance
import ru.bitcodersnn.unnstudenthub.schedule.SchedulePalette

enum class ScheduleWidgetTheme(val label: Int) {
    APP(R.string.schedule_widget_theme_app),
    SYSTEM(R.string.schedule_widget_theme_system),
    LIGHT(R.string.schedule_widget_theme_light),
    DARK(R.string.schedule_widget_theme_dark),
}

enum class ScheduleWidgetPalette(val key: String?, val label: Int) {
    APP(null, R.string.schedule_widget_palette_app),
    LIGHT_GREEN("light_green", R.string.schedule_widget_palette_light_green),
    LIGHT_BLUE("light_blue", R.string.schedule_widget_palette_light_blue),
    DARK_GREEN("dark_green", R.string.schedule_widget_palette_dark_green),
    DARK_GRAPHITE("dark_graphite", R.string.schedule_widget_palette_dark_graphite),
}

enum class ScheduleWidgetTextSize(val label: Int, val scale: Float) {
    SMALL(R.string.schedule_widget_text_small, 0.9f),
    NORMAL(R.string.schedule_widget_text_normal, 1f),
    LARGE(R.string.schedule_widget_text_large, 1.15f),
}

data class ScheduleWidgetSettings(
    val transparency: Int = 0,
    val theme: ScheduleWidgetTheme = ScheduleWidgetTheme.APP,
    val palette: ScheduleWidgetPalette = ScheduleWidgetPalette.APP,
    val textSize: ScheduleWidgetTextSize = ScheduleWidgetTextSize.NORMAL,
    val maxLessons: Int = 0,
    val showLocation: Boolean = true,
    val showLecturer: Boolean = false,
) {
    val backgroundAlpha: Int get() = ((100 - transparency.coerceIn(0, 100)) * 255 + 50) / 100

    internal fun resolvePalette(
        appearance: ScheduleAppearance,
        systemDark: Boolean = appearance.systemDark,
    ): SchedulePalette {
        val forcedDark = when (theme) {
            ScheduleWidgetTheme.APP -> null
            ScheduleWidgetTheme.SYSTEM -> systemDark
            ScheduleWidgetTheme.LIGHT -> false
            ScheduleWidgetTheme.DARK -> true
        }
        return appearance.palette(systemDark, forcedDark, palette.key)
    }

    fun toBundle(): Bundle = Bundle().apply {
        putInt(TRANSPARENCY, transparency)
        putString(THEME, theme.name)
        putString(PALETTE, palette.key)
        putString(TEXT_SIZE, textSize.name)
        putInt(MAX_LESSONS, maxLessons)
        putBoolean(SHOW_LOCATION, showLocation)
        putBoolean(SHOW_LECTURER, showLecturer)
    }

    companion object {
        const val TRANSPARENCY = "transparency"
        const val THEME = "theme"
        const val PALETTE = "palette"
        const val TEXT_SIZE = "text_size"
        const val MAX_LESSONS = "max_lessons"
        const val SHOW_LOCATION = "show_location"
        const val SHOW_LECTURER = "show_lecturer"
        val keys = listOf(TRANSPARENCY, THEME, PALETTE, TEXT_SIZE, MAX_LESSONS, SHOW_LOCATION, SHOW_LECTURER)

        fun fromBundle(bundle: Bundle): ScheduleWidgetSettings = ScheduleWidgetSettings(
            transparency = bundle.getInt(TRANSPARENCY, 0).coerceIn(0, 100),
            theme = ScheduleWidgetTheme.entries.firstOrNull { it.name == bundle.getString(THEME) }
                ?: ScheduleWidgetTheme.APP,
            palette = ScheduleWidgetPalette.entries.firstOrNull { it.key == bundle.getString(PALETTE) }
                ?: ScheduleWidgetPalette.APP,
            textSize = ScheduleWidgetTextSize.entries.firstOrNull { it.name == bundle.getString(TEXT_SIZE) }
                ?: ScheduleWidgetTextSize.NORMAL,
            maxLessons = bundle.getInt(MAX_LESSONS, 0).coerceIn(0, 6),
            showLocation = bundle.getBoolean(SHOW_LOCATION, true),
            showLecturer = bundle.getBoolean(SHOW_LECTURER, false),
        )
    }
}
