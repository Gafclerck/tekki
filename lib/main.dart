import 'package:flutter/material.dart';
import 'package:tekki/app.dart';
import 'package:tekki/features/sync/data/services/sync_orchestrator.dart';
import 'package:tekki/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencyInjection();
  di.sl<SyncOrchestrator>().start();
  runApp(const TekkiApp());
}
