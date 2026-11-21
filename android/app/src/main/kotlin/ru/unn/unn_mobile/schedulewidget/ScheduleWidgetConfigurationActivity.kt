// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.content.res.ColorStateList
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.SeekBar
import android.widget.Spinner
import android.widget.Switch
import android.widget.TextView
import androidx.core.graphics.ColorUtils
import androidx.core.view.WindowCompat
import ru.bitcodersnn.unnstudenthub.R
import ru.bitcodersnn.unnstudenthub.schedule.ScheduleAppearance
import ru.bitcodersnn.unnstudenthub.schedule.SchedulePalette

class ScheduleWidgetConfigurationActivity : Activity() {
    private var draft = ScheduleWidgetSettings()
    private var updatingControls = false
    private lateinit var preview: FrameLayout
    private val appearance by lazy { ScheduleAppearance(this) }
    private var colors: SchedulePalette? = null
    private val spinners = mutableListOf<Spinner>()

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
        bindControls()
        reflectDraft()
        renderDraft()
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
            renderDraft()
        }
    }

    private fun bindControls() {
        bindSpinner(R.id.schedule_widget_theme, ScheduleWidgetTheme.entries.map { getString(it.label) }) {
            updateDraft(draft.copy(theme = ScheduleWidgetTheme.entries[it]))
        }
        bindSpinner(R.id.schedule_widget_palette, ScheduleWidgetPalette.entries.map { getString(it.label) }) {
            updateDraft(draft.copy(palette = ScheduleWidgetPalette.entries[it]))
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
            adapter = object : ArrayAdapter<String>(
                this@ScheduleWidgetConfigurationActivity, android.R.layout.simple_spinner_item, labels,
            ) {
                override fun getView(position: Int, convertView: View?, parent: ViewGroup): View =
                    super.getView(position, convertView, parent).apply { colorSpinnerText(this) }

                override fun getDropDownView(position: Int, convertView: View?, parent: ViewGroup): View =
                    super.getDropDownView(position, convertView, parent).apply { colorSpinnerText(this) }
            }.apply {
                setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
            }
            spinners.add(this)
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
        findViewById<Spinner>(R.id.schedule_widget_palette).setSelection(draft.palette.ordinal)
        updateThemeControl()
        findViewById<Spinner>(R.id.schedule_widget_text_size).setSelection(draft.textSize.ordinal)
        findViewById<Spinner>(R.id.schedule_widget_max_lessons).setSelection(draft.maxLessons)
        findViewById<Switch>(R.id.schedule_widget_show_location).isChecked = draft.showLocation
        findViewById<Switch>(R.id.schedule_widget_show_lecturer).isChecked = draft.showLecturer
        updatingControls = false
    }

    private fun updateDraft(settings: ScheduleWidgetSettings) {
        if (updatingControls || draft == settings) return
        draft = settings
        updateThemeControl()
        renderDraft()
    }

    private fun updateThemeControl() {
        findViewById<Spinner>(R.id.schedule_widget_theme).isEnabled = draft.palette == ScheduleWidgetPalette.APP
    }

    private fun renderDraft() {
        val palette = draft.resolvePalette(appearance)
        if (colors != palette) {
            colors = palette
            applyPalette(palette)
        }
        preview.removeAllViews()
        preview.addView(ScheduleWidgetProvider.preview(this, draft).apply(this, preview))
        updateTransparency()
    }

    private fun colorSpinnerText(view: View?) {
        val palette = colors ?: return
        (view as? TextView)?.setTextColor(palette.text)
    }

    private fun applyPalette(palette: SchedulePalette) {
        val root = findViewById<View>(R.id.schedule_widget_configuration)
        root.setBackgroundColor(palette.background)
        applySystemBars(root, palette.background)
        preview.setBackgroundColor(ColorUtils.blendARGB(palette.background, palette.secondary, 0.16f))

        listOf(
            R.id.schedule_widget_configuration_title,
            R.id.schedule_widget_transparency_label,
            R.id.schedule_widget_theme_label,
            R.id.schedule_widget_palette_label,
            R.id.schedule_widget_text_size_label,
            R.id.schedule_widget_max_lessons_label,
            R.id.schedule_widget_show_location,
            R.id.schedule_widget_show_lecturer,
        ).forEach { findViewById<TextView>(it).setTextColor(palette.text) }

        listOf(R.id.schedule_widget_transparency_hint, R.id.schedule_widget_lessons_hint)
            .forEach { findViewById<TextView>(it).setTextColor(palette.secondary) }
        listOf(R.id.schedule_widget_transparency_value, R.id.schedule_widget_reset, R.id.schedule_widget_cancel)
            .forEach { findViewById<TextView>(it).setTextColor(palette.accent) }

        val accent = ColorStateList.valueOf(palette.accent)
        val mutedAccent = ColorStateList.valueOf(ColorUtils.blendARGB(palette.background, palette.accent, 0.16f))
        findViewById<TextView>(R.id.schedule_widget_save).apply {
            setTextColor(palette.text)
            backgroundTintList = mutedAccent
        }
        findViewById<SeekBar>(R.id.schedule_widget_transparency_slider).apply {
            thumbTintList = accent
            progressTintList = accent
            progressBackgroundTintList = mutedAccent
        }
        listOf(R.id.schedule_widget_show_location, R.id.schedule_widget_show_lecturer).forEach { id ->
            findViewById<Switch>(id).thumbTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_checked), intArrayOf()),
                intArrayOf(palette.accent, palette.secondary),
            )
        }
        spinners.forEach {
            it.backgroundTintList = ColorStateList.valueOf(palette.secondary)
            it.setPopupBackgroundDrawable(ColorDrawable(palette.background))
            colorSpinnerText(it.selectedView)
        }
    }

    @Suppress("DEPRECATION")
    private fun applySystemBars(root: View, background: Int) {
        window.setBackgroundDrawable(ColorDrawable(background))
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            window.statusBarColor = background
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                window.navigationBarColor = background
            }
        }
        val darkIcons = ColorUtils.calculateLuminance(background) > 0.179
        WindowCompat.getInsetsController(window, root).apply {
            isAppearanceLightStatusBars = darkIcons
            isAppearanceLightNavigationBars = darkIcons
        }
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
