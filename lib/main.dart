import 'package:clinimage_ai/pages/analyse.dart';
import 'package:clinimage_ai/pages/login.dart';
import 'package:clinimage_ai/providers/plateforme_provider.dart';
import 'package:clinimage_ai/widgets/custom_title_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'utils/couleurs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();

    WindowOptions options = const WindowOptions(
      size: Size(1200, 800),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..loadThemePreference(),
        ),
        ChangeNotifierProvider(create: (context) => PlatformService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'ClinImage AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // Définition des routes
          initialRoute: '/',
          routes: {
            '/': (context) => const MedicalAnalysisPage(),
            '/analysis': (context) => const MedicalAnalysisPage(),
          },

          // Gestion des routes non définies
          onGenerateRoute: (settings) {
            return MaterialPageRoute(builder: (context) => const AuthPage());
          },

          // Builder global avec LayoutBuilder pour la détection de plateforme
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // CORRECTION: Passer le contexte au lieu de la largeur
                final platformService = Provider.of<PlatformService>(
                  context,
                  listen: false,
                );
                platformService.init(
                  context,
                ); // ← Passer context au lieu de constraints.maxWidth
                // Sur desktop, ajoute la barre de titre personnalisée
                if (!kIsWeb && platformService.isDesktop) {
                  return Column(
                    children: [
                      const ModernTitleBar(
                        title: 'ClinImage AI',
                        isDarkMode: false,
                      ),
                      Expanded(child: child ?? const AuthPage()),
                    ],
                  );
                }

                return child ?? const AuthPage();
              },
            );
          },
        );
      },
    );
  }
}
