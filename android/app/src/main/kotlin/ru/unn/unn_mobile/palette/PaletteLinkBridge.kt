// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.palette

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PaletteLinkBridge(engine: FlutterEngine, initialIntent: Intent?) {
    private val channel = MethodChannel(
        engine.dartExecutor.binaryMessenger,
        "ru.bitcodersnn.unnstudenthub/palette_link",
    )
    private var pendingLink: String? = extractPaletteLink(initialIntent)

    init {
        channel.setMethodCallHandler { call, result ->
            handle(call, result)
        }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "consumeInitialLink" -> {
                val link = pendingLink
                pendingLink = null
                result.success(link)
            }
            else -> result.notImplemented()
        }
    }

    fun onNewIntent(intent: Intent) {
        val link = extractPaletteLink(intent) ?: return
        channel.invokeMethod("openPaletteLink", link, object : MethodChannel.Result {
            override fun success(result: Any?) { pendingLink = null }
            override fun error(code: String, message: String?, details: Any?) { pendingLink = link }
            override fun notImplemented() { pendingLink = link }
        })
    }

    companion object {
        private const val SHARE_HOST = "bitcodersnn.github.io"
        private const val SHARE_PATH_PREFIX = "/unn-mobile.assets/palette"
        private const val DEEP_LINK_SCHEME = "unnpalette"

        fun extractPaletteLink(intent: Intent?): String? {
            if (intent?.action != Intent.ACTION_VIEW) return null
            val uri = intent.data ?: return null
            val scheme = uri.scheme?.lowercase()
            val isDeepLink = scheme == DEEP_LINK_SCHEME
            val isShareLink =
                scheme == "https" &&
                    uri.host?.lowercase() == SHARE_HOST &&
                    uri.path?.startsWith(SHARE_PATH_PREFIX) == true
            return if (isDeepLink || isShareLink) uri.toString() else null
        }
    }
}
