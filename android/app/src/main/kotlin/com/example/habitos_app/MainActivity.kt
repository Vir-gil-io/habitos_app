package com.example.habitos_app

import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.habitflow/wear_sync"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "syncData") {
                    val json = call.arguments as? String
                    if (json != null) {
                        sendToWatch(json)
                        result.success(null)
                    } else {
                        result.error("NO_DATA", "No se recibió el JSON a sincronizar", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
        Wearable.getNodeClient(this).connectedNodes.addOnSuccessListener { nodes ->
            android.util.Log.d("WEAR_DEBUG", "Nodos conectados: ${nodes.size}")
            nodes.forEach { node ->
                android.util.Log.d("WEAR_DEBUG", "  - ${node.displayName} (${node.id})")
            }
        }
    }

    private fun sendToWatch(json: String) {
        val putDataMapReq = PutDataMapRequest.create("/habitflow_sync")
        putDataMapReq.dataMap.putString("payload", json)
        putDataMapReq.dataMap.putLong("timestamp", System.currentTimeMillis())
        val putDataReq = putDataMapReq.asPutDataRequest().setUrgent()
        Wearable.getDataClient(this).putDataItem(putDataReq)
    }
}