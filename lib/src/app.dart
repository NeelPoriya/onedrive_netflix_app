import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/features/admin/presentation/screens/admin_page.dart';
import 'package:onedrive_netflix/src/features/home/presentation/screens/home_page.dart';
import 'package:onedrive_netflix/src/features/login/presentation/screens/login_screen.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';

import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    final themeData = ThemeData(
      useMaterial3: true,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontFamily: 'GoogleSans',
          color: Colors.white,
        ),
      ),
    );

    GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: Constants.loginRoute,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Constants.homeRoute,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: Constants.adminRoute,
          builder: (context, state) => const AdminPage(),
        ),
      ],
      initialLocation: GlobalAuthService.instance.isLoggedIn
          ? Constants.adminRoute
          : Constants.loginRoute,
    );

    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          debugShowCheckedModeBanner: false,

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: themeData,
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          routerConfig: router,
        );
      },
    );
  }
}
