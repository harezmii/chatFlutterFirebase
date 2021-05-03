package com.example.flutter_app

import io.flutter.app.FlutterApplication
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService

class Application: FlutterActivity(), PluginRegistry.PluginRegistrantCallback {

    override fun registerWith(registry: PluginRegistry?) {

    }
}

private fun FlutterActivity.onCreate() {
}
