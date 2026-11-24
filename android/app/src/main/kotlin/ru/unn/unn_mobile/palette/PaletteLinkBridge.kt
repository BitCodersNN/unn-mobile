// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.palette

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import ru.bitcodersnn.unnstudenthub.BridgeChannels

class PaletteLinkBridge(engine: FlutterEngine, initialIntent: Intent?) {
    private val channel = MethodChannel(
        engine.dartExecutor.binaryMessenger,
        BridgeChannels.PALETTE_LINK,
    )
    private var pendingLink: String? = extractAndConsume(initialIntent)

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
        val link = extractAndConsume(intent) ?: return
        channel.invokeMethod("openPaletteLink", link, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (pendingLink == link) pendingLink = null
            }
            override fun error(code: String, message: String?, details: Any?) { pendingLink = link }
            override fun notImplemented() { pendingLink = link }
        })
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val SHARE_HOST = "bitcodersnn.github.io"
        private const val SHARE_PATH_PREFIX = "/unn-mobile.assets/palette"
        private const val DEEP_LINK_SCHEME = "unnpalette"
        private const val DEEP_LINK_HOST = "import"
        private const val MAX_LINK_LENGTH = 8192
        private const val EXTRA_CONSUMED = "ru.bitcodersnn.unnstudenthub.palette.CONSUMED"

        fun markConsumed(intent: Intent?) {
            intent?.putExtra(EXTRA_CONSUMED, true)
        }

        private fun extractAndConsume(intent: Intent?): String? {
            val link = extractPaletteLink(intent) ?: return null
            markConsumed(intent)
            return link
        }

        fun extractPaletteLink(intent: Intent?): String? {
            if (intent?.action != Intent.ACTION_VIEW) return null
            if (intent.getBooleanExtra(EXTRA_CONSUMED, false)) return null
            val uri = intent.data ?: return null
            val raw = uri.toString()
            if (raw.length > MAX_LINK_LENGTH) return null
            val scheme = uri.scheme?.lowercase()
            val host = uri.host?.lowercase()
            val isDeepLink = scheme == DEEP_LINK_SCHEME && host == DEEP_LINK_HOST
            val path = normalizePath(uri.path)
            val isShareLink =
                scheme == "https" &&
                    host == SHARE_HOST &&
                    (path == SHARE_PATH_PREFIX || path.startsWith("$SHARE_PATH_PREFIX/"))
            return if (isDeepLink || isShareLink) raw else null
        }

        private fun normalizePath(rawPath: String?): String {
            if (rawPath.isNullOrEmpty()) return ""
            val parts = ArrayDeque<String>()
            for (segment in rawPath.split('/')) {
                when (segment) {
                    "", "." -> Unit
                    ".." -> if (parts.isNotEmpty()) parts.removeLast()
                    else -> parts.addLast(segment)
                }
            }
            return if (parts.isEmpty()) "/" else parts.joinToString("/", prefix = "/")
        }
    }
}
