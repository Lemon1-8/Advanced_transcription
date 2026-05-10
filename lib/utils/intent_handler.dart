import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class FileIntentHandler {
  static const _channel = MethodChannel('com.example.advanced_transcription/intent');

  static Future<String?> getInitialFile() async {
    try {
      return await _channel.invokeMethod<String?>('getInitialFile');
    } catch (_) {
      return null;
    }
  }

  static void listenForFiles(void Function(String path) onFile) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFileReceived') {
        onFile(call.arguments as String);
      }
    });
  }

  static Future<String> readFileContent(String path) async {
    final file = File(path);
    return await file.readAsString();
  }

  static Future<void> cleanupFile(String path) async {
    try {
      await File(path).delete();
    } catch (_) {}
  }
}
