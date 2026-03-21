// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edu_auth/core/di/injection_container.dart';
import 'package:edu_auth/core/logging/app_logger.dart';
import 'package:edu_auth/features/auth/presentation/controllers/locale_controller.dart';
import 'package:edu_auth/firebase_options.dart';
import 'package:edu_auth/l10n/app_localizations.dart';
import 'package:edu_auth/routing/app_router.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';

Future<void> main() async {
  // Step 1: Flutter binding (MUST be first)
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Firebase (MUST be before runApp)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.info('main: Firebase initialised ✓');

  // Step 3: Orientation lock (mobile only — web has no orientation API)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Step 4: System UI chrome (mobile only)
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:           Colors.transparent,
      statusBarIconBrightness:  Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E21),
    ));
  }

  // Step 5: Dependency injection (AFTER Firebase)
  await initDependencies();
  AppLogger.info('main: dependencies initialised ✓');

  runApp(const ProviderScope(child: EduAuthApp()));
}

class EduAuthApp extends ConsumerWidget {
  const EduAuthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig:               router,
      title:                      'EduPlatform',
      debugShowCheckedModeBanner: false,
      theme:                      AppTheme.dark,
      locale:                     locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
