import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/models/user.model.dart';
import 'package:onedrive_netflix/src/utils/app_button_styles.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';
import 'package:onedrive_netflix/src/utils/device_utils.dart';

class MainNavigation extends StatefulWidget {
  final VoidCallback requestHomeFocus;
  final bool isDrawerOpen;
  const MainNavigation(
      {super.key, required this.requestHomeFocus, required this.isDrawerOpen});

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

  Widget _buildTVNavigation() {
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
      child: Center(
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          direction: Axis.vertical,
          children: [
            TextButton.icon(
              autofocus: widget.isDrawerOpen,
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

  Widget _buildMobileNavigation() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double itemsFontSize = screenWidth / 20;
    double buttonWidth = 200.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
      ),
      width: screenWidth,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: buttonWidth,
                    child: TextButton.icon(
                      style: AppButtonStyles.transparentButton,
                      autofocus: widget.isDrawerOpen,
                      onPressed: () {
                        if (!Constants.homeRoute.contains(currentRoute)) {
                          GoRouter.of(context).push(Constants.homeRoute);
                        }
                        widget.requestHomeFocus();
                      },
                      label: Text(
                        'Home',
                        style: TextStyle(
                          fontSize: itemsFontSize,
                        ),
                      ),
                      icon: Icon(
                        Icons.home,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: buttonWidth,
                    child: TextButton.icon(
                      style: AppButtonStyles.transparentButton,
                      onPressed: () {
                        if (!Constants.searchRoute.contains(currentRoute)) {
                          GoRouter.of(context).push(Constants.searchRoute);
                        }
                        widget.requestHomeFocus();
                      },
                      label: Text('Search',
                          style: TextStyle(
                            fontSize: itemsFontSize,
                          )),
                      icon: const Icon(
                        Icons.search,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: buttonWidth,
                    child: TextButton.icon(
                      style: AppButtonStyles.transparentButton,
                      onPressed: () {
                        if (!Constants.listRoute.contains(currentRoute)) {
                          GoRouter.of(context).push(Constants.listRoute);
                        }
                        widget.requestHomeFocus();
                      },
                      label: Text('A-Z List',
                          style: TextStyle(
                            fontSize: itemsFontSize,
                          )),
                      icon: const Icon(
                        Icons.list_alt,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (user != null && user!.isAdmin)
                    SizedBox(
                      width: buttonWidth,
                      child: TextButton.icon(
                        style: AppButtonStyles.transparentButton,
                        onPressed: () {
                          if (!Constants.adminRoute.contains(currentRoute)) {
                            GoRouter.of(context).push(Constants.adminRoute);
                          }
                        },
                        label: Text('Admin',
                            style: TextStyle(
                              fontSize: itemsFontSize,
                            )),
                        icon: Icon(
                          Icons.admin_panel_settings,
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.white.withOpacity(0.8),
                size: 50,
              ),
              onPressed: () {
                widget.requestHomeFocus();
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DeviceUtils.isTVDevice(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error loading device information.');
          } else {
            final bool isTV = snapshot.data as bool;
            if (isTV) {
              return _buildTVNavigation();
            } else {
              return _buildMobileNavigation();
            }
          }
        });
  }

  void _loadUser() async {
    User? getUser = await GlobalAuthService.instance.getUser();
    if (!mounted) return;
    setState(() {
      user = getUser;
    });
  }
}
