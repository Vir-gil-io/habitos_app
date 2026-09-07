import 'dart:convert';
import 'package:flutter/services.dart';

class WearSyncChannel {
  static const _channel = MethodChannel('com.habitflow/wear_sync');

  static Future<void> sync(Map<String, dynamic> payload) async {
    try {
      await _channel.invokeMethod('syncData', jsonEncode(payload));
    } catch (_) {
      // Falla silenciosamente si no hay reloj emparejado — no debe romper la app
    }
  }
}