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
    val dark: Boolean? = null,
) {
    fun lessonAccent(lesson: ScheduleLesson): Int =
        subjects[lesson.typeKey] ?: lesson.accentColor ?: accent

    companion object {
        private const val KEY_BACKGROUND = "background"
        private const val KEY_TEXT = "text"
        private const val KEY_SECONDARY = "secondary"
        private const val KEY_ACCENT = "accent"
        private const val KEY_SUBJECTS = "subjects"
        private const val KEY_DARK = "dark"

        fun fallback(context: Context, dark: Boolean): SchedulePalette {
            val nightContext = context.createConfigurationContext(
                Configuration(context.resources.configuration).apply {
                    val nightMode = if (dark) Configuration.UI_MODE_NIGHT_YES else Configuration.UI_MODE_NIGHT_NO
                    uiMode = (uiMode and Configuration.UI_MODE_NIGHT_MASK.inv()) or nightMode
                },
            )
            return SchedulePalette(
                background = nightContext.getColor(R.color.schedule_widget_background),
                text = nightContext.getColor(R.color.schedule_widget_text),
                secondary = nightContext.getColor(R.color.schedule_widget_secondary),
                accent = nightContext.getColor(R.color.schedule_accent),
                dark = dark,
            )
        }

        fun fromJson(json: JSONObject): SchedulePalette {
            val subjects = json.getJSONObject(KEY_SUBJECTS)
            val dark = if (json.has(KEY_DARK) && !json.isNull(KEY_DARK)) json.getBoolean(KEY_DARK) else null
            return SchedulePalette(
                background = json.getLong(KEY_BACKGROUND).toInt(),
                text = json.getLong(KEY_TEXT).toInt(),
                secondary = json.getLong(KEY_SECONDARY).toInt(),
                accent = json.getLong(KEY_ACCENT).toInt(),
                subjects = subjects.keys().asSequence().associateWith { subjects.getLong(it).toInt() },
                dark = dark,
            )
        }
    }
}

internal data class SchedulePaletteOption(
    val key: String?,
    val label: String,
)

internal class ScheduleAppearance(context: Context) {
    private val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
    private val data by lazy {
        preferences.getString(KEY, null)?.let { runCatching { JSONObject(it) }.getOrNull() }
    }
    private val appMode by lazy { data?.optString(KEY_MODE) }
    private val context = context.applicationContext

    val options: List<SchedulePaletteOption> by lazy {
        val array = data?.optJSONArray(KEY_OPTIONS) ?: return@lazy emptyList()
        buildList {
            for (index in 0 until array.length()) {
                val item = array.optJSONObject(index) ?: continue
                val key = (item.opt(KEY_OPTION_KEY) as? String)?.takeIf { it.isNotEmpty() } ?: continue
                val label = (item.opt(KEY_OPTION_LABEL) as? String)?.takeIf { it.isNotEmpty() } ?: continue
                add(SchedulePaletteOption(key = key, label = label))
            }
        }
    }

    val systemDark: Boolean get() = context.resources.configuration.uiMode and
        Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES

    fun palette(
        systemDark: Boolean,
        forcedDark: Boolean? = null,
        paletteKey: String? = null,
    ): SchedulePalette {
        val overrideKey = paletteKey?.takeIf { it.isNotEmpty() }
        val overridePalette = overrideKey?.let(::paletteForKey)
        val useDark = if (overrideKey != null) {
            overridePalette?.dark ?: overrideKey.startsWith(DARK_PREFIX)
        } else {
            forcedDark ?: when (appMode) {
                MODE_DARK -> true
                MODE_LIGHT -> false
                else -> systemDark
            }
        }
        val activeKey = data?.optString(if (useDark) KEY_DARK else KEY_LIGHT)?.takeIf { it.isNotEmpty() }
        val activePalette = activeKey?.let(::paletteForKey)
        return overridePalette ?: activePalette ?: SchedulePalette.fallback(context, useDark)
    }

    private fun paletteForKey(key: String): SchedulePalette? =
        data?.optJSONObject(KEY_PALETTES)?.optJSONObject(key)?.let {
            runCatching { SchedulePalette.fromJson(it) }.getOrNull()
        }

    fun save(value: String): Boolean {
        val json = JSONObject(value)
        requireString(json, KEY_MODE)
        requireString(json, KEY_LIGHT)
        requireString(json, KEY_DARK)
        val palettes = json.getJSONObject(KEY_PALETTES)
        palettes.keys().forEach { SchedulePalette.fromJson(palettes.getJSONObject(it)) }
        if (preferences.getString(KEY, null) == value) return false
        preferences.edit().putString(KEY, value).apply()
        return true
    }

    private fun requireString(json: JSONObject, key: String): String {
        require(!json.isNull(key)) { "Missing $key" }
        val value = json.opt(key)
        require(value is String) { "Invalid $key" }
        return value
    }

    private companion object {
        const val PREFERENCES = "schedule_appearance"
        const val KEY = "appearance"
        const val KEY_MODE = "mode"
        const val KEY_LIGHT = "light"
        const val KEY_DARK = "dark"
        const val KEY_PALETTES = "palettes"
        const val KEY_OPTIONS = "options"
        const val KEY_OPTION_KEY = "key"
        const val KEY_OPTION_LABEL = "label"
        const val MODE_LIGHT = "light"
        const val MODE_DARK = "dark"
        const val DARK_PREFIX = "dark_"
    }
}
