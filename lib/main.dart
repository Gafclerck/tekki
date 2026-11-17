import 'package:flutter/material.dart';
import 'package:tekki/app.dart';
import 'package:tekki/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencyInjection();
  runApp(const TekkiApp());
}
