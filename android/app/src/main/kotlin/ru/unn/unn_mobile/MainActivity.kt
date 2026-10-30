package ru.bitcodersnn.unnstudenthub

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts.PickMultipleVisualMedia
import androidx.core.content.FileProvider
import androidx.core.net.toUri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import ru.bitcodersnn.unnstudenthub.schedulewidget.ScheduleWidgetBridge
import kotlinx.coroutines.*
import org.json.JSONObject
import java.io.File

const val FILE_PICKER_REQUEST = 1

const val UPLOAD_FILE_PICKER_REQUEST = 2

const val FILE_CHANNEL = "ru.bitcodersnn.unnstudenthub/files"

const val FILE_PICKER_EVENTS = "ru.bitcodersnn.unnstudenthub/file_events"

const val ARGUMENT_ERROR = "ARGUMENT_ERROR"

const val EXECUTION_ERROR = "EXECUTION_ERROR"

data class OpenResult(val type: Int, val message: String)


class MainActivity : FlutterActivity() {
    private var scheduleWidgetBridge: ScheduleWidgetBridge? = null
    class Container<T>(
        obj: T?,
    ) {
        val data: T? = obj
    }

    fun serializeOpenResult(input : OpenResult) : String {
        val json = JSONObject();
        json.put("type", input.type)
        json.put("message", input.message)
        return json.toString()
    }

    companion object {
        var pickedFileUri: Container<Uri>? = null

        var pickedUploadUris: Container<List<Uri>>? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        scheduleWidgetBridge = ScheduleWidgetBridge(this, flutterEngine, intent)
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

                    val uri : Uri;

                    if (uriString.startsWith("/")) {
                        val file = File(uriString)
                        uri  = FileProvider.getUriForFile(context, "ru.bitcodersnn.studenthub.fileprovider", file)
                    }
                    else {
                        uri = uriString.toUri()
                    }

                    try {
                        viewFileFromUri(uri, mimeType, result)
                    } catch (e: ActivityNotFoundException) {
                        result.success(serializeOpenResult(OpenResult(1, "Could not find the app to open")))
                    } catch (e: Exception) {
                        result.success(serializeOpenResult(OpenResult(4, "{Exception happened: \"$e\"}")))
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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        scheduleWidgetBridge?.onNewIntent(intent)
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
        result: MethodChannel.Result
    ) {
        val fileIntent = Intent(Intent.ACTION_VIEW)
        fileIntent.setDataAndType(uri, mimeType)
        fileIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startActivity(fileIntent)
        result.success(serializeOpenResult(OpenResult(0, "done")))
    }
}
