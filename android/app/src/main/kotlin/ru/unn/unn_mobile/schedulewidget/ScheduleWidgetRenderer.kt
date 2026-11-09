// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import java.util.Calendar
import ru.bitcodersnn.unnstudenthub.R
import ru.bitcodersnn.unnstudenthub.schedule.ScheduleLesson
import ru.bitcodersnn.unnstudenthub.schedule.ScheduleNavigation
import ru.bitcodersnn.unnstudenthub.schedule.SchedulePalette
import ru.bitcodersnn.unnstudenthub.schedule.ScheduleSnapshot
import ru.bitcodersnn.unnstudenthub.schedule.ScheduleTime

class ScheduleWidgetRenderer(
    private val context: Context,
    private val data: ScheduleSnapshot?,
    private val now: Long,
    private val settings: ScheduleWidgetSettings,
) {
    private val colors = themedContext(settings.theme)
    private val lightColors by lazy { themedContext(ScheduleWidgetTheme.LIGHT) }
    private val darkColors by lazy { themedContext(ScheduleWidgetTheme.DARK) }

    private fun themedContext(theme: ScheduleWidgetTheme): Context = context.createConfigurationContext(
        Configuration(context.resources.configuration).apply {
            val nightMode = when (theme) {
                ScheduleWidgetTheme.SYSTEM -> uiMode and Configuration.UI_MODE_NIGHT_MASK
                ScheduleWidgetTheme.LIGHT -> Configuration.UI_MODE_NIGHT_NO
                ScheduleWidgetTheme.DARK -> Configuration.UI_MODE_NIGHT_YES
            }
            uiMode = (uiMode and Configuration.UI_MODE_NIGHT_MASK.inv()) or nightMode
        },
    )

    fun render(height: Float): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.schedule_widget)
        applyColor(views, R.id.schedule_widget_background, "setColorFilter", R.color.schedule_widget_background)
        views.setInt(R.id.schedule_widget_background, "setImageAlpha", settings.backgroundAlpha)
        applyColor(views, R.id.schedule_widget_settings, "setColorFilter", R.color.schedule_widget_secondary)
        styleText(views, R.id.schedule_widget_title, 16f, R.color.schedule_widget_text)
        styleText(views, R.id.schedule_widget_date, 12f, R.color.schedule_widget_secondary)
        styleText(views, R.id.schedule_widget_empty, 14f, R.color.schedule_widget_secondary)
        styleText(views, R.id.schedule_widget_footer, 11f, R.color.schedule_accent)

        val day = ScheduleTime.dayStart(now)
        val tomorrow = (day.clone() as Calendar).apply { add(Calendar.DAY_OF_MONTH, 1) }.timeInMillis
        val covered = data != null && data.validFrom <= day.timeInMillis && data.validUntil >= tomorrow
        val today = data?.lessons?.filter { it.start >= day.timeInMillis && it.start < tomorrow }.orEmpty()
        val remaining = today.filter { it.end > now }
        val date = ScheduleTime.format(now, "EEE, d MMM")
        views.setTextViewText(R.id.schedule_widget_date,
            listOf(date, data?.ownerLabel.orEmpty()).filter { it.isNotBlank() }.joinToString(" · "))
        val message = when {
            data == null -> R.string.schedule_widget_sign_in
            !covered -> R.string.schedule_widget_outdated
            today.isEmpty() -> R.string.schedule_widget_empty
            else -> R.string.schedule_widget_finished
        }
        val showLessons = covered && remaining.isNotEmpty()
        views.setViewVisibility(R.id.schedule_widget_lessons, if (showLessons) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.schedule_widget_empty, if (showLessons) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.schedule_widget_empty, context.getString(message))
        views.removeAllViews(R.id.schedule_widget_lessons)
        val capacity = lessonCapacity(height)
        if (showLessons) {
            remaining.take(capacity).forEach { lesson ->
                views.addView(R.id.schedule_widget_lessons, lessonView(lesson))
            }
        }
        val more = if (showLessons) (remaining.size - capacity).coerceAtLeast(0) else 0
        views.setTextViewText(R.id.schedule_widget_footer, if (more > 0)
            context.getString(R.string.schedule_widget_more, more) else context.getString(R.string.schedule_widget_open))
        views.setOnClickPendingIntent(R.id.schedule_widget_root, ScheduleNavigation.pendingIntent(context))
        return views
    }

    private fun lessonCapacity(height: Float): Int {
        val fontScale = context.resources.configuration.fontScale.coerceAtLeast(1f) * settings.textSize.scale
        val extraLines = (if (settings.showLocation) 1 else 0) + (if (settings.showLecturer) 1 else 0)
        val rowHeight = (68f + 17f * extraLines) * fontScale
        val headerHeight = 40f + 80f * fontScale
        val available = ((height - headerHeight) / rowHeight).toInt().coerceIn(1, 6)
        return if (settings.maxLessons == 0) available else minOf(available, settings.maxLessons)
    }

    private fun lessonView(lesson: ScheduleLesson): RemoteViews {
        val row = RemoteViews(context.packageName, R.layout.schedule_widget_lesson)
        val accent = SchedulePalette.lessonAccent(colors, lesson)
        row.setInt(R.id.schedule_widget_lesson_accent, "setColorFilter", accent)
        val current = lesson.start <= now && now < lesson.end
        row.setViewVisibility(R.id.schedule_widget_lesson_background, if (current) View.VISIBLE else View.GONE)
        row.setInt(R.id.schedule_widget_lesson_background, "setColorFilter", accent)
        row.setInt(R.id.schedule_widget_lesson_background, "setImageAlpha", 20)
        row.setTextViewText(R.id.schedule_widget_lesson_title, lesson.title)
        row.setTextViewText(R.id.schedule_widget_lesson_detail,
            if (current) context.getString(R.string.schedule_widget_now) else lesson.type)
        row.setTextViewText(R.id.schedule_widget_lesson_location, lesson.location)
        row.setViewVisibility(R.id.schedule_widget_lesson_location,
            if (settings.showLocation && lesson.location.isNotBlank()) View.VISIBLE else View.GONE)
        row.setTextViewText(R.id.schedule_widget_lesson_lecturer, lesson.lecturer)
        row.setViewVisibility(R.id.schedule_widget_lesson_lecturer,
            if (settings.showLecturer && lesson.lecturer.isNotBlank()) View.VISIBLE else View.GONE)
        row.setTextViewText(R.id.schedule_widget_lesson_start, ScheduleTime.format(lesson.start, "HH:mm"))
        row.setTextViewText(R.id.schedule_widget_lesson_end, ScheduleTime.format(lesson.end, "HH:mm"))
        styleText(row, R.id.schedule_widget_lesson_title, 13f, R.color.schedule_widget_text)
        styleText(row, R.id.schedule_widget_lesson_detail, 11f, R.color.schedule_widget_secondary)
        styleText(row, R.id.schedule_widget_lesson_location, 11f, R.color.schedule_widget_secondary)
        styleText(row, R.id.schedule_widget_lesson_lecturer, 11f, R.color.schedule_widget_secondary)
        styleText(row, R.id.schedule_widget_lesson_start, 13f, R.color.schedule_widget_text)
        styleText(row, R.id.schedule_widget_lesson_end, 11f, R.color.schedule_widget_secondary)
        return row
    }

    private fun styleText(views: RemoteViews, id: Int, size: Float, colorId: Int) {
        views.setTextViewTextSize(id, TypedValue.COMPLEX_UNIT_SP, size * settings.textSize.scale)
        applyColor(views, id, "setTextColor", colorId)
    }

    private fun applyColor(views: RemoteViews, id: Int, method: String, colorId: Int) {
        if (settings.theme == ScheduleWidgetTheme.SYSTEM && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            views.setColorInt(id, method, lightColors.getColor(colorId), darkColors.getColor(colorId))
        } else {
            views.setInt(id, method, color(colorId))
        }
    }

    private fun color(id: Int): Int = colors.getColor(id)
}
