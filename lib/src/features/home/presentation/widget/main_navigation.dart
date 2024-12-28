import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';

class MainNavigation extends StatelessWidget {
  final VoidCallback requestHomeFocus;
  const MainNavigation({super.key, required this.requestHomeFocus});

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
                GoRouter.of(context).push(Constants.homeRoute);
                requestHomeFocus();
              },
              label: const Text('Home'),
              icon: const Icon(Icons.home),
            ),
            TextButton.icon(
              onPressed: () {
                GoRouter.of(context).push(Constants.searchRoute);
                requestHomeFocus();
              },
              label: const Text('Search'),
              icon: const Icon(Icons.search),
            ),
            TextButton.icon(
              onPressed: () {
                GoRouter.of(context).push(Constants.listRoute);
                requestHomeFocus();
              },
              label: const Text('A-Z List'),
              icon: const Icon(Icons.list_alt),
            ),
            TextButton.icon(
              onPressed: () {
                GoRouter.of(context).push(Constants.adminRoute);
              },
              label: Text('Admin'),
              icon: Icon(Icons.admin_panel_settings),
            ),
          ],
        ),
      ),
    );
  }
}
