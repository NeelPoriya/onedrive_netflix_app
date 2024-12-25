import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/home_content.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/home_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusScopeNode _drawerFocusScopeNode =
      FocusScopeNode(debugLabel: 'Drawer');
  final FocusScopeNode _homeFocusScopeNode = FocusScopeNode(debugLabel: 'Home');

  @override
  void dispose() {
    _drawerFocusScopeNode.dispose();
    _homeFocusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          bool check = await _onWillPop();
          if (check && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: <Widget>[
            // This is the main content.
            FocusScope(
              autofocus: true,
              node: _homeFocusScopeNode,
              onKeyEvent: _onKeyForHomeScreenFocus,
              child: HomeContent(),
            ),
            // addes a black background when the drawer is focused
            Positioned.fill(
              child: AnimatedContainer(
                color: _drawerFocusScopeNode.hasFocus
                    ? Colors.black.withAlpha(150)
                    : Colors.transparent,
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 200),
              ),
            ),
            // This is the drawer.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _drawerFocusScopeNode.hasFocus ? 0 : -200,
              top: 0,
              bottom: 0,
              curve: Curves.easeInOut,
              child: FocusScope(
                node: _drawerFocusScopeNode,
                onKeyEvent: _onKeyForDrawerScreenFocus,
                child: HomeNavigation(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: deprecated_member_use
  KeyEventResult _onKeyForHomeScreenFocus(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent ||
        event.logicalKey != LogicalKeyboardKey.arrowLeft) {
      return KeyEventResult.ignored;
    }
    if (node is! FocusScopeNode) {
      return KeyEventResult.ignored;
    }

    if (_homeFocusScopeNode.focusInDirection(TraversalDirection.left)) {
      return KeyEventResult.handled;
    }

    _drawerFocusScopeNode.requestFocus();
    setState(() {});
    return KeyEventResult.handled;
  }

  KeyEventResult _onKeyForDrawerScreenFocus(FocusNode node, KeyEvent event) {
    if (event is! KeyUpEvent ||
        event.logicalKey != LogicalKeyboardKey.arrowRight) {
      return KeyEventResult.ignored;
    }

    _homeFocusScopeNode.requestFocus();
    setState(() {});
    return KeyEventResult.handled;
  }

  Future<bool> _onWillPop() async {
    if (_drawerFocusScopeNode.hasFocus) return false;
    _drawerFocusScopeNode.requestFocus();
    return false;
  }
}
