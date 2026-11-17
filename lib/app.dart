import 'package:flutter/material.dart';
import 'package:tekki/core/constants/app_constants.dart';
import 'package:tekki/core/theme/app_theme.dart';

class TekkiApp extends StatelessWidget {
  const TekkiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const _TekkiHomePlaceholder(),
    );
  }
}

class _TekkiHomePlaceholder extends StatelessWidget {
  const _TekkiHomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 64,
                      color: Color(0xFF133E59),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tekki',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gestion de caisse et passeport financier pour commercants',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
