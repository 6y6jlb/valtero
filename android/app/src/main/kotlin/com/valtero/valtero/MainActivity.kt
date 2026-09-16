package com.valtero.valtero

import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val emailChannel = "com.valtero.valtero/email"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, emailChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "sendEmailWithAttachment") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val to = call.argument<String>("to").orEmpty()
                val subject = call.argument<String>("subject").orEmpty()
                val body = call.argument<String>("body").orEmpty()
                val filePath = call.argument<String>("filePath").orEmpty()
                try {
                    val file = File(filePath)
                    if (!file.exists()) {
                        result.error("FILE_MISSING", "Log file not found", null)
                        return@setMethodCallHandler
                    }
                    val uri = FileProvider.getUriForFile(
                        this,
                        "${applicationContext.packageName}.fileprovider",
                        file,
                    )
                    val intent = Intent(Intent.ACTION_SEND).apply {
                        // Prefer email clients over generic share targets.
                        type = "message/rfc822"
                        putExtra(Intent.EXTRA_EMAIL, arrayOf(to))
                        putExtra(Intent.EXTRA_SUBJECT, subject)
                        putExtra(Intent.EXTRA_TEXT, body)
                        putExtra(Intent.EXTRA_STREAM, uri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        // Chooser targets often miss FLAG_GRANT_* from the
                        // wrapping intent — ClipData + explicit grants fix that.
                        clipData = ClipData.newUri(contentResolver, "log", uri)
                    }
                    val matches = packageManager.queryIntentActivities(
                        intent,
                        PackageManager.MATCH_DEFAULT_ONLY,
                    )
                    for (info in matches) {
                        grantUriPermission(
                            info.activityInfo.packageName,
                            uri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION,
                        )
                    }
                    startActivity(Intent.createChooser(intent, null))
                    result.success(true)
                } catch (e: Exception) {
                    result.error("EMAIL_FAILED", e.message, null)
                }
            }
    }
}
