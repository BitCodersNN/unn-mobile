// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.SeekBar
import android.widget.Spinner
import android.widget.Switch
import android.widget.TextView
import ru.bitcodersnn.unnstudenthub.R

class ScheduleWidgetConfigurationActivity : Activity() {
    private var draft = ScheduleWidgetSettings()
    private var updatingControls = false
    private lateinit var preview: FrameLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)
        val widgetId = intent.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID,
        )
        val manager = AppWidgetManager.getInstance(this)
        val provider = manager.getAppWidgetInfo(widgetId)?.provider
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID ||
            provider != ComponentName(this, ScheduleWidgetProvider::class.java)) {
            finish()
            return
        }
        val preferences = ScheduleWidgetPreferences(this)
        draft = savedInstanceState?.getBundle(DRAFT_STATE)?.let(ScheduleWidgetSettings::fromBundle)
            ?: preferences.read(widgetId)
        setContentView(R.layout.schedule_widget_configuration)
        preview = findViewById(R.id.schedule_widget_preview)
        renderPreview()
        bindControls()
        reflectDraft()
        findViewById<View>(R.id.schedule_widget_cancel).setOnClickListener { finish() }
        findViewById<View>(R.id.schedule_widget_save).setOnClickListener {
            preferences.save(widgetId, draft)
            ScheduleWidgetProvider.updateAll(this)
            setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId))
            finish()
        }
        findViewById<View>(R.id.schedule_widget_reset).setOnClickListener {
            draft = ScheduleWidgetSettings()
            reflectDraft()
            renderPreview()
        }
    }

    private fun bindControls() {
        bindSpinner(R.id.schedule_widget_theme, ScheduleWidgetTheme.entries.map { getString(it.label) }) {
            updateDraft(draft.copy(theme = ScheduleWidgetTheme.entries[it]))
        }
        bindSpinner(R.id.schedule_widget_text_size, ScheduleWidgetTextSize.entries.map { getString(it.label) }) {
            updateDraft(draft.copy(textSize = ScheduleWidgetTextSize.entries[it]))
        }
        bindSpinner(R.id.schedule_widget_max_lessons,
            listOf(getString(R.string.schedule_widget_lessons_auto)) +
                (1..6).map { getString(R.string.schedule_widget_lessons_limit, it) }) {
            updateDraft(draft.copy(maxLessons = it))
        }
        findViewById<Switch>(R.id.schedule_widget_show_location).setOnCheckedChangeListener { _, checked ->
            updateDraft(draft.copy(showLocation = checked))
        }
        findViewById<Switch>(R.id.schedule_widget_show_lecturer).setOnCheckedChangeListener { _, checked ->
            updateDraft(draft.copy(showLecturer = checked))
        }
        findViewById<SeekBar>(R.id.schedule_widget_transparency_slider)
            .setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(seekBar: SeekBar, progress: Int, fromUser: Boolean) {
                    if (updatingControls) return
                    draft = draft.copy(transparency = progress)
                    updateTransparency()
                }
                override fun onStartTrackingTouch(seekBar: SeekBar) = Unit
                override fun onStopTrackingTouch(seekBar: SeekBar) = Unit
            })
    }

    private fun bindSpinner(id: Int, labels: List<String>, onSelected: (Int) -> Unit) {
        findViewById<Spinner>(id).apply {
            adapter = ArrayAdapter(this@ScheduleWidgetConfigurationActivity,
                android.R.layout.simple_spinner_item, labels).apply {
                setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
            }
            onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
                    if (!updatingControls) onSelected(position)
                }
                override fun onNothingSelected(parent: AdapterView<*>) = Unit
            }
        }
    }

    private fun reflectDraft() {
        updatingControls = true
        findViewById<SeekBar>(R.id.schedule_widget_transparency_slider).progress = draft.transparency
        findViewById<Spinner>(R.id.schedule_widget_theme).setSelection(draft.theme.ordinal)
        findViewById<Spinner>(R.id.schedule_widget_text_size).setSelection(draft.textSize.ordinal)
        findViewById<Spinner>(R.id.schedule_widget_max_lessons).setSelection(draft.maxLessons)
        findViewById<Switch>(R.id.schedule_widget_show_location).isChecked = draft.showLocation
        findViewById<Switch>(R.id.schedule_widget_show_lecturer).isChecked = draft.showLecturer
        updatingControls = false
        updateTransparency()
    }

    private fun updateDraft(settings: ScheduleWidgetSettings) {
        if (updatingControls || draft == settings) return
        draft = settings
        renderPreview()
    }

    private fun renderPreview() {
        preview.removeAllViews()
        preview.addView(ScheduleWidgetProvider.preview(this, draft).apply(this, preview))
    }

    private fun updateTransparency() {
        findViewById<TextView>(R.id.schedule_widget_transparency_value).text =
            getString(R.string.schedule_widget_transparency_value, draft.transparency)
        preview.findViewById<ImageView>(R.id.schedule_widget_background).imageAlpha = draft.backgroundAlpha
    }

    override fun onSaveInstanceState(outState: Bundle) {
        outState.putBundle(DRAFT_STATE, draft.toBundle())
        super.onSaveInstanceState(outState)
    }

    private companion object {
        const val DRAFT_STATE = "draft"
    }
}
