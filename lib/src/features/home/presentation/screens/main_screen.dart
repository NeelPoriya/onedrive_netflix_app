import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onedrive_netflix/src/features/home/presentation/widget/main_navigation.dart';
import 'package:onedrive_netflix/src/utils/top_navbar.dart';
import 'package:talker/talker.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.child});
  final Widget child;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusScopeNode _drawerFocusScopeNode =
      FocusScopeNode(debugLabel: 'Drawer');
  final FocusScopeNode _homeFocusScopeNode = FocusScopeNode(debugLabel: 'Home');
  final Talker _talker = Talker();

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
        onPopInvokedWithResult: (didPop, result) {
          if (_drawerFocusScopeNode.hasFocus) {
            _homeFocusScopeNode.requestFocus();
            setState(() {});
          }
        },
        child: Stack(
          children: <Widget>[
            FocusScope(
              autofocus: true,
              node: _homeFocusScopeNode,
              onKeyEvent: _onKeyForHomeScreenFocus,
              child: Stack(
                children: [
                  widget.child,
                  TopNavbar(
                    requestDrawerFocus: () {
                      _drawerFocusScopeNode.requestFocus();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            NavigationOverlay(drawerFocusScopeNode: _drawerFocusScopeNode),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _drawerFocusScopeNode.hasFocus ? 0 : -200,
              top: 0,
              bottom: 0,
              curve: Curves.easeInOut,
              child: FocusScope(
                node: _drawerFocusScopeNode,
                onKeyEvent: _onKeyForDrawerScreenFocus,
                child: MainNavigation(
                  requestHomeFocus: () {
                    _talker.info('requesting home focus');
                    _homeFocusScopeNode.requestFocus();
                    setState(() {});
                  },
                ),
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
    // _drawerFocusScopeNode.requestFocus();
    // setState(() {});
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
}

class NavigationOverlay extends StatelessWidget {
  const NavigationOverlay({
    super.key,
    required FocusScopeNode drawerFocusScopeNode,
  }) : _drawerFocusScopeNode = drawerFocusScopeNode;

  final FocusScopeNode _drawerFocusScopeNode;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !_drawerFocusScopeNode.hasFocus,
        child: AnimatedContainer(
          color: _drawerFocusScopeNode.hasFocus
              ? Colors.black.withAlpha(150)
              : Colors.transparent,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 200),
        ),
      ),
    );
  }
}
