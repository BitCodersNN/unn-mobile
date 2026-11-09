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
import android.widget.RemoteViews
import java.util.Calendar
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

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        ScheduleWidgetPreferences(context).remove(appWidgetIds)
    }

    companion object {
        const val OPEN_SCHEDULE = "open_schedule_widget"
        private const val UPDATE_ACTION = "ru.bitcodersnn.unnstudenthub.UPDATE_SCHEDULE_WIDGET"

        fun preview(context: Context, settings: ScheduleWidgetSettings): RemoteViews =
            ScheduleWidgetRenderer(context, ScheduleWidgetData.read(context),
                System.currentTimeMillis(), settings).render(260f).apply {
                setOnClickPendingIntent(R.id.schedule_widget_root, null)
                setOnClickPendingIntent(R.id.schedule_widget_settings, null)
            }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, ScheduleWidgetProvider::class.java))
            if (ids.isEmpty()) return
            val data = ScheduleWidgetData.read(context)
            val now = System.currentTimeMillis()
            ids.forEach { id -> manager.updateAppWidget(id, render(context, manager, id, data, now)) }
            val midnight = ScheduleWidgetTime.dayStart(now).apply { add(Calendar.DAY_OF_MONTH, 1) }.timeInMillis
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
            val settings = ScheduleWidgetPreferences(context).read(id)
            val renderer = ScheduleWidgetRenderer(context, data, now, settings)
            val settingsIntent = PendingIntent.getActivity(
                context, id, Intent(context, ScheduleWidgetConfigurationActivity::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
                }, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            fun atHeight(height: Float): RemoteViews =
                renderer.render(height).apply {
                    setOnClickPendingIntent(R.id.schedule_widget_settings, settingsIntent)
                }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val sizes = widgetSizes(options)
                    .filter { it.width > 0 && it.height > 0 }
                    .distinct()
                    .take(16)
                if (sizes.isNotEmpty()) {
                    return RemoteViews(sizes.associateWith { size ->
                        atHeight(size.height)
                    })
                }
            }
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 180)
            val maxHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, minHeight)
                .coerceAtLeast(minHeight)
            return RemoteViews(
                atHeight(minHeight.toFloat()),
                atHeight(maxHeight.toFloat()),
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

        private fun alarmManager(context: Context): AlarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        private fun updateIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
            context, 0, Intent(context, ScheduleWidgetProvider::class.java).setAction(UPDATE_ACTION),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
