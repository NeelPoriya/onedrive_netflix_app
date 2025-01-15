import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onedrive_netflix/src/models/user.model.dart';
import 'package:onedrive_netflix/src/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

class GlobalAuthService {
  // Singleton instance
  static final GlobalAuthService instance = GlobalAuthService._();
  final Talker _talker = Talker();
  final DatabaseService _databaseService = DatabaseService();

  static const List<String> scopes = [
    'https://www.googleapis.com/auth/contacts.readonly'
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: scopes);

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  // Private constructor for the singleton
  GlobalAuthService._();

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        _talker.debug("Account is null.");
        return null;
      }

      return account;
    } catch (e) {
      _talker.error("Error signing in with Google: $e");
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    _isLoggedIn = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString('user');

    if (json != null) {
      _isLoggedIn = true;
      User localUser = User.fromJson(json);

      DataSnapshot userFromDatabase =
          await _databaseService.getData('users/${localUser.id}');
      if (userFromDatabase.exists) {
        return User.fromMap(userFromDatabase.value as Map<dynamic, dynamic>,
            userFromDatabase.key ?? '');
      }
    }
    return null;
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    _isLoggedIn = false;
    await _googleSignIn.signOut();
  }
}
