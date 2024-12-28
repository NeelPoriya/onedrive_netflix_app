import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/features/admin/presentation/screens/admin_page.dart';
import 'package:onedrive_netflix/src/features/azlist/presentation/screens/azlist_screen.dart';
import 'package:onedrive_netflix/src/features/home/presentation/screens/main_screen.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/home_page.dart';
import 'package:onedrive_netflix/src/features/login/presentation/screens/login_screen.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/features/search/presentation/screens/search_page.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';

class Routes {
  static GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: Constants.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Constants.homeRoute,
        builder: (context, state) => MainScreen(
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: Constants.searchRoute,
        builder: (context, state) => MainScreen(
          child: const SearchPage(),
        ),
      ),
      GoRoute(
        path: Constants.listRoute,
        builder: (context, state) => MainScreen(
          child: AzlistScreen(),
        ),
      ),
      GoRoute(
        path: Constants.adminRoute,
        builder: (context, state) => const AdminPage(),
      ),
    ],
    initialLocation: GlobalAuthService.instance.isLoggedIn
        ? Constants.homeRoute
        : Constants.loginRoute,
  );
}
