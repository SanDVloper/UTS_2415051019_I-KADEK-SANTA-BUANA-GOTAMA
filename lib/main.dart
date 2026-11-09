import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'widgets/responsive_scaffold.dart';

void main() {
  runApp(const KaryaSetaraApp());
}

class KaryaSetaraApp extends StatelessWidget {
  const KaryaSetaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.highContrastTheme,
      home: const ResponsiveScaffold(),
    );
  }
}
