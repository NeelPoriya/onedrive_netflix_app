import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/features/admin/presentation/screens/admin_page.dart';
import 'package:onedrive_netflix/src/features/alphabetical/presentation/screens/alphabetical_list_screen.dart';
import 'package:onedrive_netflix/src/features/home/presentation/screens/main_screen.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/home_page.dart';
import 'package:onedrive_netflix/src/features/login/presentation/screens/login_screen.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/features/media/presentation/screens/media_details_page.dart';
import 'package:onedrive_netflix/src/features/search/presentation/screens/search_page.dart';
import 'package:onedrive_netflix/src/features/test/test_page.dart';
import 'package:onedrive_netflix/src/features/video/presentation/screens/video_player_page.dart';
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
          child: const AlphabeticalListScreen(),
        ),
      ),
      GoRoute(
        path: Constants.adminRoute,
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        path: Constants.mediaDetailsRoute,
        builder: (context, state) => const MediaDetailsPage(),
      ),
      GoRoute(
        path: Constants.videoPlayerRoute,
        builder: (context, state) => const VideoPlayerPage(),
      ),
      GoRoute(
        path: Constants.testRoute,
        builder: (context, state) => const TestPage(),
      ),
    ],
    initialLocation: GlobalAuthService.instance.isLoggedIn
        ? Constants.homeRoute
        : Constants.loginRoute,
    // initialLocation: Constants.testRoute,
  );
}
