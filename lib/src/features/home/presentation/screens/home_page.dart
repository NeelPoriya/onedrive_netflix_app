import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  double groupAlignment = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: 0,
            groupAlignment: groupAlignment,
            onDestinationSelected: (int index) {
              if (index == 2) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final router = GoRouter.of(context);
                            await GlobalAuthService.instance.signOut();

                            if (!mounted) return;

                            navigator.pop();
                            router.go(Constants.loginRoute);
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  },
                );

                return;
              }

              if (index == 1) {
                context.push(Constants.adminRoute);
              }
            },
            labelType: labelType,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.supervised_user_circle_outlined),
                selectedIcon: Icon(Icons.supervised_user_circle),
                label: Text('Admin'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.logout_outlined),
                selectedIcon: Icon(Icons.logout),
                label: Text('Logout'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Text('Label type: ${labelType.name}'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
