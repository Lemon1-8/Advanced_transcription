import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/app_provider.dart';
import 'utils/intent_handler.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 检查是否从外部打开 .json 文件
  final pendingFile = await FileIntentHandler.getInitialFile();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: App(pendingImportPath: pendingFile),
    ),
  );
}
