import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/features/admin/presentation/widgets/accounts_page.dart';
import 'package:onedrive_netflix/src/features/admin/presentation/widgets/folders_page.dart';
import 'package:onedrive_netflix/src/features/admin/presentation/widgets/sync_page.dart';
import 'package:onedrive_netflix/src/features/admin/presentation/widgets/users_page.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 3;
  PageController _pageController = PageController();
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  double groupAlignment = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            groupAlignment: 0.0,
            onDestinationSelected: (int index) {
              if (index == 4) {
                context.push(Constants.homeRoute);
              }

              if (index == 5) {
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
                            router.push(Constants.loginRoute);
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  },
                );

                return;
              }

              setState(() {
                _selectedIndex = index;
                _pageController.jumpToPage(index);
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.account_box_outlined),
                selectedIcon: Icon(Icons.account_box),
                label: Text('Accounts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: Text('Folders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.sync_outlined),
                selectedIcon: Icon(Icons.sync),
                label: Text('Sync'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
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
            child: PageView(
              controller: _pageController,
              children: <Widget>[
                const AccountsPage(),
                const FoldersPage(),
                const UsersPage(),
                SyncPage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
