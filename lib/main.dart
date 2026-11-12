import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/accessibility_provider.dart';
import 'providers/job_provider.dart';
import 'providers/user_provider.dart';
import 'widgets/responsive_scaffold.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()..fetchJobs()),
      ],
      child: const KaryaSetaraApp(),
    ),
  );
}

class KaryaSetaraApp extends StatelessWidget {
  const KaryaSetaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accProvider = context.watch<AccessibilityProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: accProvider.isHighContrast ? AppTheme.highContrastTheme : AppTheme.lightTheme,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(accProvider.textScaleFactor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const ResponsiveScaffold(),
    );
  }
}
