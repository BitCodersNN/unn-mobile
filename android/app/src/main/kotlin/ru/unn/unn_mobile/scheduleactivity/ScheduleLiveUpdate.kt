// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.scheduleactivity

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import ru.bitcodersnn.unnstudenthub.MainActivity
import ru.bitcodersnn.unnstudenthub.R
import ru.bitcodersnn.unnstudenthub.schedulewidget.ScheduleWidgetData
import ru.bitcodersnn.unnstudenthub.schedulewidget.ScheduleWidgetProvider
import ru.bitcodersnn.unnstudenthub.schedulewidget.WidgetLesson

object ScheduleLiveUpdate {
    private const val CHANNEL = "schedule_live_updates"
    private const val NOTIFICATION_ID = 2041
    private const val REQUEST_PROMOTED_ONGOING = "android.requestPromotedOngoing"
    const val UPDATE = "ru.bitcodersnn.unnstudenthub.SCHEDULE_LIVE_UPDATE"
    const val DISMISS = "ru.bitcodersnn.unnstudenthub.DISMISS_SCHEDULE_LIVE_UPDATE"
    const val LESSON_ID = "lesson_id"

    private fun WidgetLesson.identity() = "$start|$end|$title|$location"

    fun dismiss(context: Context, id: String) {
        val preferences = context.getSharedPreferences(ScheduleActivitySettings.PREFERENCES, Context.MODE_PRIVATE)
        val dismissed = preferences.getStringSet(ScheduleActivitySettings.DISMISSED, emptySet()).orEmpty() + id
        preferences.edit().putStringSet(ScheduleActivitySettings.DISMISSED, dismissed).apply()
        update(context)
    }

    fun clear(context: Context) {
        context.getSharedPreferences(ScheduleActivitySettings.PREFERENCES, Context.MODE_PRIVATE)
            .edit().remove(ScheduleActivitySettings.DISMISSED).apply()
        update(context)
    }

    fun update(context: Context) {
        if (Build.VERSION.SDK_INT < 36) return
        val manager = context.getSystemService(NotificationManager::class.java)
        val alarms = context.getSystemService(AlarmManager::class.java)
        val alarmIntent = PendingIntent.getBroadcast(context, 0,
            Intent(context, ScheduleActivityReceiver::class.java).setAction(UPDATE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val minuteIntent = PendingIntent.getBroadcast(context, 1,
            Intent(context, ScheduleActivityReceiver::class.java).setAction(UPDATE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        alarms.cancel(alarmIntent)
        alarms.cancel(minuteIntent)
        val settings = ScheduleActivitySettings.read(context)
        if (settings.mode !in listOf("full", "brief") || !manager.areNotificationsEnabled()) {
            manager.cancel(NOTIFICATION_ID)
            return
        }
        val now = System.currentTimeMillis()
        val data = ScheduleWidgetData.read(context)
        if (data == null || now < data.validFrom || now >= data.validUntil) {
            manager.cancel(NOTIFICATION_ID)
            return
        }
        val preferences = context.getSharedPreferences(ScheduleActivitySettings.PREFERENCES, Context.MODE_PRIVATE)
        val validLessons = data.lessons.filter { it.end > it.start && it.end > now }
        val ids = validLessons.map { it.identity() }.toSet()
        val dismissed = preferences.getStringSet(ScheduleActivitySettings.DISMISSED, emptySet()).orEmpty().intersect(ids)
        preferences.edit().putStringSet(ScheduleActivitySettings.DISMISSED, dismissed).apply()
        fun displayEnd(lesson: WidgetLesson) = if (settings.mode == "brief")
            minOf(lesson.end, lesson.start + settings.initialMillis) else lesson.end
        val lessons = validLessons.filter { it.identity() !in dismissed }
        val current = lessons.firstOrNull { it.start <= now && now < displayEnd(it) }
            ?: lessons.firstOrNull { it.start - settings.beforeMillis <= now && now < it.start }
        if (current == null) {
            manager.cancel(NOTIFICATION_ID)
        } else {
            post(context, manager, current, now, displayEnd(current))
        }
        val boundaries = lessons.flatMap { listOf(it.start - settings.beforeMillis, it.start, displayEnd(it)) }
        val next = (boundaries + data.validUntil)
            .filter { it > now }.minOrNull() ?: return
        if (alarms.canScheduleExactAlarms()) {
            alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, alarmIntent)
        } else {
            alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, alarmIntent)
        }
        val nextMinute = (now / 60_000 + 1) * 60_000
        if (current != null && nextMinute < next) {
            if (alarms.canScheduleExactAlarms()) {
                alarms.setExact(AlarmManager.RTC, nextMinute, minuteIntent)
            } else {
                alarms.set(AlarmManager.RTC, nextMinute, minuteIntent)
            }
        }
    }

    @android.annotation.TargetApi(36)
    private fun post(context: Context, manager: NotificationManager, lesson: WidgetLesson, now: Long, displayEnd: Long) {
        manager.createNotificationChannel(NotificationChannel(CHANNEL, "Ход занятия", NotificationManager.IMPORTANCE_LOW))
        val active = now >= lesson.start
        val target = if (active) lesson.end else lesson.start
        val minutes = ((target - now + 59_999) / 60_000).coerceAtLeast(1)
        val label = if (active) "Осталось $minutes мин" else "До начала $minutes мин"
        val details = listOf(label, lesson.type, lesson.location).filter { it.isNotBlank() }.joinToString(" · ")
        val open = Intent(context, MainActivity::class.java).apply {
            putExtra(ScheduleWidgetProvider.OPEN_SCHEDULE, true)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        val dismiss = PendingIntent.getBroadcast(context, 1,
            Intent(context, ScheduleActivityReceiver::class.java).setAction(DISMISS).putExtra(LESSON_ID, lesson.identity()),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val origin = if (active) lesson.start else lesson.start - ScheduleActivitySettings.read(context).beforeMillis
        val maximum = (target - origin).coerceAtLeast(1)
        val progress = (((now - origin).coerceIn(0, maximum) * 1000) / maximum).toInt()
        val accent = Color.rgb(68, 133, 127)
        val style = Notification.ProgressStyle()
            .setProgressSegments(listOf(Notification.ProgressStyle.Segment(1000).setColor(accent)))
            .setProgress(progress)
        val notification = Notification.Builder(context, CHANNEL)
            .setSmallIcon(R.drawable.ic_schedule_widget_calendar)
            .setContentTitle(lesson.title)
            .setContentText(details)
            .setStyle(style)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setColor(accent)
            .setWhen(target)
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
            .setTimeoutAfter((displayEnd - now).coerceAtLeast(1))
            .setVisibility(Notification.VISIBILITY_PRIVATE)
            .setPublicVersion(Notification.Builder(context, CHANNEL)
                .setSmallIcon(R.drawable.ic_schedule_widget_calendar)
                .setContentTitle("Расписание").setContentText("Занятие").build())
            .setContentIntent(PendingIntent.getActivity(context, 1, open,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
            .setDeleteIntent(dismiss)
            .addAction(Notification.Action.Builder(null, "Скрыть пару", dismiss).build())
            .addExtras(Bundle().apply { putBoolean(REQUEST_PROMOTED_ONGOING, true) })
            .build()
        manager.notify(NOTIFICATION_ID, notification)
    }
}
