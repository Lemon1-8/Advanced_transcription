import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<Uint8List?> captureWidget(GlobalKey key) async {
  try {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}

Future<File> saveToTemp(Uint8List bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file;
}

Future<File> saveToDocuments(Uint8List bytes, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory('${dir.path}/images');
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }
  final file = File('${imagesDir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file;
}
