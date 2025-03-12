package ru.unn.unn_mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.Intent
import android.net.Uri
import android.os.Looper
import android.os.Handler
import androidx.annotation.NonNull
import java.util.concurrent.ArrayBlockingQueue

const val FILE_PICKER_REQUEST = 1

const val FILE_CHANNEL = "ru.unn.unn_mobile/files"

const val FILE_PICKER_EVENTS = "ru.unn.unn_mobile/file_events"

class MainActivity: FlutterActivity() {
    class UriContainer (uri: Uri?) {
        val uri: Uri? = uri;
    }

    companion object {
        var pickedFileUri: UriContainer? = null;
    }
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_PICKER_EVENTS).setStreamHandler(FilePickerHandler)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_CHANNEL).setMethodCallHandler methodCallback@{
            call, result ->
                when(call.method) {
                    "pickDirectory" -> {
                            val fileName = call.argument<String>("fileName")
                            val mimeType = call.argument<String>("mimeType")
                            if (fileName == null || mimeType == null) {
                                result.error("1", "Argumets \"fileName\" and \"mimeType\" expected but not received", null)
                                return@methodCallback
                            }
                            
                            selectExternalStorageFolder(fileName, mimeType)
                            result.success(0)
                        }
                    "viewFile" -> {
                        val uriString = call.argument<String>("uri")
                        val mimeType = call.argument<String>("mimeType")
                        if (uriString == null || mimeType == null) {
                            result.error("1", "Argumets \"uri\" and \"mimeType\" expected but not received", null)
                            return@methodCallback
                        }
                        // Будет UB при некорректном URI :) Я хз как это отлавливать
                        // Будем надеяться, что Android предоставляет только хорошие uri 
                        // через их API, а я правильно их использую
                        // ведь здесь уже приложение по-настоящему крашнуться может
                        // Правда следующий try-catch может нас спасти :)
                        val uri = Uri.parse(uriString)

                        try {
                            viewFileFromUri(uri, mimeType)
                            result.success(0)
                        }
                        catch (e : Exception) {
                            result.error("2", "Exception happened: " + e.toString(), null)
                        }
                    }
                    else -> result.notImplemented()
                }    
        }
    }    

    private fun selectExternalStorageFolder(fileName: String, mimeType: String) {
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        startActivityForResult(intent, FILE_PICKER_REQUEST)
    }

    // receive Uri for selected directory
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            FILE_PICKER_REQUEST -> 
                pickedFileUri = UriContainer(data?.data)
            
        }
    }

    object FilePickerHandler : EventChannel.StreamHandler {

        private val handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null
        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            val delay :Long = 100
            val r: Runnable = object : Runnable {
                override fun run() {
                    handler.post {
                        if(pickedFileUri != null) {
                            val uri = pickedFileUri?.uri
                            pickedFileUri = null
                            eventSink?.success(uri?.toString())
                        }
                        else if (eventSink != null) {
                            handler.postDelayed(this, delay)
                        }
                    }
                }
            }
            handler.post(r);

        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }
    }
    // use ContentResolver to write file by Uri
    // private fun copyFileToExternalStorage(destination: Uri) {
    //     //val yourFile: File = 

    //     try {
    //         val outputStream = contentResolver.openOutputStream(destination) ?: return
    //         outputStream.write(yourFile.readBytes())
    //         outputStream.close()
    //     } catch (e: IOException) {
    //         e.printStackTrace()
    //     }
    // }

    private fun viewFileFromUri(uri: Uri, mimeType: String) {
        val fileIntent = Intent(Intent.ACTION_VIEW)
        fileIntent.setDataAndType(uri, mimeType)
        fileIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startActivity(fileIntent)
    }
}
