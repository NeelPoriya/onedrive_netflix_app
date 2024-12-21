import 'package:flutter/material.dart';

class AdminNavigation extends StatefulWidget {
  final int selectedIndex;
  final double groupAlignment;
  final void Function(int) onDestinationSelected;

  const AdminNavigation({
    super.key,
    required this.selectedIndex,
    required this.groupAlignment,
    required this.onDestinationSelected,
  });

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        
      ],
    );
  }
}
