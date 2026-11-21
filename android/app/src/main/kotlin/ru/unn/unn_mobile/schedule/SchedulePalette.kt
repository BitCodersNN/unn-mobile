// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedule

import android.content.Context
import android.content.res.Configuration
import org.json.JSONObject
import ru.bitcodersnn.unnstudenthub.R

internal data class SchedulePalette(
    val background: Int,
    val text: Int,
    val secondary: Int,
    val accent: Int,
    val subjects: Map<String, Int> = emptyMap(),
) {
    fun lessonAccent(lesson: ScheduleLesson): Int =
        subjects[lesson.typeKey] ?: lesson.accentColor ?: accent

    companion object {
        fun fallback(context: Context, dark: Boolean): SchedulePalette {
            val nightContext = context.createConfigurationContext(
                Configuration(context.resources.configuration).apply {
                    val nightMode = if (dark) Configuration.UI_MODE_NIGHT_YES else Configuration.UI_MODE_NIGHT_NO
                    uiMode = (uiMode and Configuration.UI_MODE_NIGHT_MASK.inv()) or nightMode
                },
            )
            return SchedulePalette(
                nightContext.getColor(R.color.schedule_widget_background),
                nightContext.getColor(R.color.schedule_widget_text),
                nightContext.getColor(R.color.schedule_widget_secondary),
                nightContext.getColor(R.color.schedule_accent),
            )
        }

        fun fromJson(json: JSONObject): SchedulePalette {
            val subjects = json.getJSONObject("subjects")
            return SchedulePalette(
                json.getLong("background").toInt(),
                json.getLong("text").toInt(),
                json.getLong("secondary").toInt(),
                json.getLong("accent").toInt(),
                subjects.keys().asSequence().associateWith { subjects.getLong(it).toInt() },
            )
        }
    }
}

internal class ScheduleAppearance(context: Context) {
    private val preferences = context.getSharedPreferences("schedule_appearance", Context.MODE_PRIVATE)
    private val data = preferences.getString(KEY, null)?.let { runCatching { JSONObject(it) }.getOrNull() }
    private val appMode = data?.optString("mode")
    private val context = context.applicationContext

    val systemDark: Boolean get() = context.resources.configuration.uiMode and
        Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES

    fun palette(
        systemDark: Boolean,
        forcedDark: Boolean? = null,
        paletteKey: String? = null,
    ): SchedulePalette {
        val dark = paletteKey?.startsWith("dark_") ?: forcedDark ?: when (appMode) {
            "dark" -> true
            "light" -> false
            else -> systemDark
        }
        val key = paletteKey ?: data?.optString(if (dark) "dark" else "light")
        val json = key?.let { data?.optJSONObject("palettes")?.optJSONObject(it) }
        return json?.let { runCatching { SchedulePalette.fromJson(it) }.getOrNull() }
            ?: SchedulePalette.fallback(context, dark)
    }

    fun save(value: String): Boolean {
        val json = JSONObject(value)
        val palettes = json.getJSONObject("palettes")
        palettes.keys().forEach { SchedulePalette.fromJson(palettes.getJSONObject(it)) }
        if (preferences.getString(KEY, null) == value) return false
        preferences.edit().putString(KEY, value).apply()
        return true
    }

    private companion object {
        const val KEY = "appearance"
    }
}
