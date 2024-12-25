import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeNavigation extends StatelessWidget {
  const HomeNavigation({super.key});

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
              onPressed: () {},
              label: Text('Home'),
              icon: Icon(Icons.home),
            ),
            TextButton.icon(
              onPressed: () {},
              label: Text('Trending'),
              icon: Icon(Icons.trending_up),
            ),
            TextButton.icon(
              onPressed: () {},
              label: Text('Search'),
              icon: Icon(Icons.search),
            ),
            TextButton.icon(
              onPressed: () {
                GoRouter.of(context).push('/admin');
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
