import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/models/user.model.dart';
import 'package:onedrive_netflix/src/utils/notification_button.dart';

class TopNavbar extends StatefulWidget {
  const TopNavbar({
    super.key,
    required this.requestDrawerFocus,
  });
  final VoidCallback requestDrawerFocus;

  @override
  State<TopNavbar> createState() => _TopNavbarState();
}

class _TopNavbarState extends State<TopNavbar> {
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    User? getUser = await GlobalAuthService.instance.getUser();
    if (!mounted) return;
    setState(() {
      user = getUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                widget.requestDrawerFocus();
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (user != null && user!.isAdmin) NotificationButton(),
            const SizedBox(width: 10),
            user != null ? UserProfileButton(user: user) : const SizedBox(),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}

class UserProfileButton extends StatelessWidget {
  const UserProfileButton({
    super.key,
    required this.user,
  });

  final User? user;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(48.0),
        ),
        child: Image.network(
          user!.photoUrl,
          width: 30,
          height: 30,
          fit: BoxFit.cover,
        ),
      ),
      onPressed: () {
        showAboutDialog(context: context);
      },
      selectedIcon: Icon(Icons.circle),
    );
  }
}
