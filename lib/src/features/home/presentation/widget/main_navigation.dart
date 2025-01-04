import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/models/user.model.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';

class MainNavigation extends StatefulWidget {
  final VoidCallback requestHomeFocus;
  const MainNavigation({super.key, required this.requestHomeFocus});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  User? user;
  String currentRoute = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String route = GoRouterState.of(context).uri.pathSegments.last;
    setState(() {
      currentRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(0, 0, 0, 0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      width: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              autofocus: true,
              onPressed: () {
                if (!Constants.homeRoute.contains(currentRoute)) {
                  GoRouter.of(context).push(Constants.homeRoute);
                }
                widget.requestHomeFocus();
              },
              label: const Text('Home'),
              icon: const Icon(Icons.home),
            ),
            TextButton.icon(
              onPressed: () {
                if (!Constants.searchRoute.contains(currentRoute)) {
                  GoRouter.of(context).push(Constants.searchRoute);
                }
                widget.requestHomeFocus();
              },
              label: const Text('Search'),
              icon: const Icon(Icons.search),
            ),
            TextButton.icon(
              onPressed: () {
                if (!Constants.listRoute.contains(currentRoute)) {
                  GoRouter.of(context).push(Constants.listRoute);
                }
                widget.requestHomeFocus();
              },
              label: const Text('A-Z List'),
              icon: const Icon(Icons.list_alt),
            ),
            if (user != null && user!.isAdmin)
              TextButton.icon(
                onPressed: () {
                  if (!Constants.adminRoute.contains(currentRoute)) {
                    GoRouter.of(context).push(Constants.adminRoute);
                  }
                },
                label: Text('Admin'),
                icon: Icon(Icons.admin_panel_settings),
              ),
          ],
        ),
      ),
    );
  }

  void _loadUser() async {
    User? getUser = await GlobalAuthService.instance.getUser();
    if (!mounted) return;
    setState(() {
      user = getUser;
    });
  }
}
