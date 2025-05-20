package ru.unn.unn_mobile

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import androidx.core.net.toUri
import androidx.activity.result.contract.ActivityResultContracts.PickMultipleVisualMedia
import androidx.activity.result.PickVisualMediaRequest

const val FILE_PICKER_REQUEST = 1

const val UPLOAD_FILE_PICKER_REQUEST = 2

const val FILE_CHANNEL = "ru.unn.unn_mobile/files"

const val FILE_PICKER_EVENTS = "ru.unn.unn_mobile/file_events"

const val ARGUMENT_ERROR = "ARGUMENT_ERROR"

const val EXECUTION_ERROR = "EXECUTION_ERROR"

class MainActivity : FlutterActivity() {
    class Container<T>(
        obj: T?,
    ) {
        val data: T? = obj
    }

    companion object {
        var pickedFileUri: Container<Uri>? = null

        var pickedUploadUris: Container<List<Uri>>? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FILE_PICKER_EVENTS,
        ).setStreamHandler(FilePickerHandler)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FILE_CHANNEL,
        ).setMethodCallHandler methodCallback@{ call, result ->
            when (call.method) {
                "pickDirectory" -> {
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType")
                    if (fileName == null || mimeType == null) {
                        result.error(
                            ARGUMENT_ERROR,
                            "Argumets \"fileName\" and \"mimeType\" expected but not received",
                            null,
                        )
                        return@methodCallback
                    }

                    selectExternalStorageFolder(fileName, mimeType)
                    result.success(0)
                }
                "viewFile" -> {
                    val uriString = call.argument<String>("uri")
                    val mimeType = call.argument<String>("mimeType")
                    if (uriString == null || mimeType == null) {
                        result.error(
                            ARGUMENT_ERROR,
                            "Argumets \"uri\" and \"mimeType\" expected but not received",
                            null,
                        )
                        return@methodCallback
                    }

                    val uri = uriString.toUri()

                    try {
                        viewFileFromUri(uri, mimeType)
                        result.success(0)
                    } catch (e: Exception) {
                        result.error(EXECUTION_ERROR, "Exception happened: $e", null)
                    }
                }
                "pickUploadFiles" -> {
                    val fromGallery = call.argument<Boolean>("gallery") ?: false
                    if (fromGallery) {
                        openGalleryFilePicker()
                    } else {
                        openUploadFilePicker()
                    }
                    result.success(0)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openGalleryFilePicker() {
        startActivityForResult(
            PickMultipleVisualMedia(5).createIntent(
                context,
                PickVisualMediaRequest.Builder().build(),
            ),
            UPLOAD_FILE_PICKER_REQUEST,
        )
    }

    private fun openUploadFilePicker() {
        val intent =
            Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "*/*"
                putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
            }
        startActivityForResult(intent, UPLOAD_FILE_PICKER_REQUEST)
    }

    private fun selectExternalStorageFolder(
        fileName: String,
        mimeType: String,
    ) {
        val intent =
            Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = mimeType
                putExtra(Intent.EXTRA_TITLE, fileName)
            }
        startActivityForResult(intent, FILE_PICKER_REQUEST)
    }

    // receive Uri for selected directory
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            FILE_PICKER_REQUEST ->
                pickedFileUri = Container(data?.data)
            UPLOAD_FILE_PICKER_REQUEST -> {
                val uris: MutableList<Uri?> =
                    MutableList(
                        data?.clipData?.itemCount ?: 0,
                    ) { i ->
                        data?.clipData?.getItemAt(i)?.uri
                    }
                if (data != null && data.data != null) {
                    uris.add(data.data)
                }
                pickedUploadUris = Container(uris.filterNotNull())
            }
        }
    }

    object FilePickerHandler : EventChannel.StreamHandler {
        private var eventSink: EventChannel.EventSink? = null
        private val scope = CoroutineScope(Dispatchers.Main)
        private var job: Job? = null

        override fun onListen(
            argument: Any?,
            sink: EventChannel.EventSink,
        ) {
            eventSink = sink
            val checkDelay: Long = 100

            job =
                scope.launch {
                    while (eventSink != null) {
                        if (pickedFileUri != null) {
                            val uri = pickedFileUri?.data
                            pickedFileUri = null
                            eventSink?.success(uri?.toString())
                        }
                        if (pickedUploadUris != null) {
                            val uris = pickedUploadUris?.data
                            pickedUploadUris = null
                            eventSink?.success(uris?.map({ u -> u.toString() }))
                        }
                        delay(checkDelay)
                    }
                }
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
            job?.cancel()
        }
    }

    private fun viewFileFromUri(
        uri: Uri,
        mimeType: String,
    ) {
        val fileIntent = Intent(Intent.ACTION_VIEW)
        fileIntent.setDataAndType(uri, mimeType)
        fileIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startActivity(fileIntent)
    }
}
