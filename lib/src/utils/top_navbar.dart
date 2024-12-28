import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget {
  const TopNavbar({
    super.key,
    required this.requestDrawerFocus,
  });
  final VoidCallback requestDrawerFocus;

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
                requestDrawerFocus();
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings,
                )),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.person,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
