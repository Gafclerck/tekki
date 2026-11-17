import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekki/core/theme/app_theme.dart';

extension WidgetTesterX on WidgetTester {
  /// Pumps a widget wrapped in MaterialApp with Tekki Light Theme.
  Future<void> pumpTekkiWidget(
    Widget widget, {
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    NavigatorObserver? navigatorObserver,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        navigatorObservers: [
          ?navigatorObserver,
        ],
        home: Scaffold(
          body: widget,
        ),
      ),
      duration: duration,
      phase: phase,
    );
  }
}
