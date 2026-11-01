// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import ru.bitcodersnn.unnstudenthub.MainActivity
import ru.bitcodersnn.unnstudenthub.R

class ScheduleWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        updateAll(context)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        updateAll(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action in listOf(UPDATE_ACTION, Intent.ACTION_DATE_CHANGED,
                Intent.ACTION_TIME_CHANGED, Intent.ACTION_TIMEZONE_CHANGED)) {
            updateAll(context)
        }
    }

    override fun onDisabled(context: Context) {
        alarmManager(context).cancel(updateIntent(context))
    }

    companion object {
        const val OPEN_SCHEDULE = "open_schedule_widget"
        private const val UPDATE_ACTION = "ru.bitcodersnn.unnstudenthub.UPDATE_SCHEDULE_WIDGET"

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, ScheduleWidgetProvider::class.java))
            if (ids.isEmpty()) return
            val data = ScheduleWidgetData.read(context)
            val now = System.currentTimeMillis()
            ids.forEach { id -> manager.updateAppWidget(id, render(context, manager, id, data, now)) }
            val midnight = dayStart(now).apply { add(Calendar.DAY_OF_MONTH, 1) }.timeInMillis
            val nextBoundary = data?.lessons?.flatMap { listOf(it.start, it.end) }
                ?.filter { it > now && it < midnight }?.minOrNull() ?: midnight
            alarmManager(context).set(AlarmManager.RTC, nextBoundary, updateIntent(context))
        }

        private fun render(
            context: Context,
            manager: AppWidgetManager,
            id: Int,
            data: ScheduleWidgetData?,
            now: Long,
        ): RemoteViews {
            val options = manager.getAppWidgetOptions(id)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val sizes = widgetSizes(options)
                    .filter { it.width > 0 && it.height > 0 }
                    .distinct()
                    .take(16)
                if (sizes.isNotEmpty()) {
                    return RemoteViews(sizes.associateWith { size ->
                        renderAtHeight(context, data, now, size.height)
                    })
                }
            }
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 180)
            val maxHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, minHeight)
                .coerceAtLeast(minHeight)
            return RemoteViews(
                renderAtHeight(context, data, now, minHeight.toFloat()),
                renderAtHeight(context, data, now, maxHeight.toFloat()),
            )
        }

        @Suppress("DEPRECATION")
        private fun widgetSizes(options: Bundle): List<SizeF> =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                options.getParcelableArrayList(AppWidgetManager.OPTION_APPWIDGET_SIZES, SizeF::class.java)
                    .orEmpty()
            } else {
                options.getParcelableArrayList<SizeF>(AppWidgetManager.OPTION_APPWIDGET_SIZES)
                    .orEmpty()
            }

        private fun renderAtHeight(
            context: Context,
            data: ScheduleWidgetData?,
            now: Long,
            height: Float,
        ): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.schedule_widget)
            val day = dayStart(now)
            val tomorrow = (day.clone() as Calendar).apply { add(Calendar.DAY_OF_MONTH, 1) }.timeInMillis
            val covered = data != null && data.validFrom <= day.timeInMillis && data.validUntil >= tomorrow
            val today = data?.lessons?.filter { it.start >= day.timeInMillis && it.start < tomorrow }.orEmpty()
            val remaining = today.filter { it.end > now }
            val date = SimpleDateFormat("EEE, d MMM", Locale("ru")).format(Date(now))
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
            val fontScale = context.resources.configuration.fontScale.coerceAtLeast(1f)
            val capacity = ((height - 100) / (68 * fontScale)).toInt().coerceIn(1, 6)
            if (showLessons) {
                remaining.take(capacity).forEach { lesson ->
                    views.addView(R.id.schedule_widget_lessons, lessonView(context, lesson, now))
                }
            }
            val more = if (showLessons) (remaining.size - capacity).coerceAtLeast(0) else 0
            views.setTextViewText(R.id.schedule_widget_footer, if (more > 0)
                context.getString(R.string.schedule_widget_more, more) else context.getString(R.string.schedule_widget_open))
            val intent = Intent(context, MainActivity::class.java).apply {
                action = OPEN_SCHEDULE
                putExtra(OPEN_SCHEDULE, true)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            views.setOnClickPendingIntent(R.id.schedule_widget_root, PendingIntent.getActivity(
                context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
            return views
        }

        private fun lessonView(context: Context, lesson: WidgetLesson, now: Long): RemoteViews {
            val row = RemoteViews(context.packageName, R.layout.schedule_widget_lesson)
            val current = lesson.start <= now && now < lesson.end
            val formatter = SimpleDateFormat("HH:mm", Locale("ru"))
            row.setTextViewText(R.id.schedule_widget_lesson_title, lesson.title)
            row.setTextViewText(R.id.schedule_widget_lesson_detail, listOf(
                if (current) context.getString(R.string.schedule_widget_now) else lesson.type,
                lesson.location,
            ).filter { it.isNotBlank() }.joinToString(" · "))
            row.setTextViewText(R.id.schedule_widget_lesson_start, formatter.format(Date(lesson.start)))
            row.setTextViewText(R.id.schedule_widget_lesson_end, formatter.format(Date(lesson.end)))
            row.setInt(R.id.schedule_widget_lesson_root, "setBackgroundResource",
                if (current) R.drawable.schedule_widget_current else 0)
            return row
        }

        private fun dayStart(time: Long): Calendar = Calendar.getInstance().apply {
            timeInMillis = time
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        private fun alarmManager(context: Context): AlarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        private fun updateIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
            context, 0, Intent(context, ScheduleWidgetProvider::class.java).setAction(UPDATE_ACTION),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
