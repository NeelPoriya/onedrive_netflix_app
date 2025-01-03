import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

class GlobalAuthService {
  // Singleton instance
  static final GlobalAuthService instance = GlobalAuthService._();
  final Talker _talker = Talker();

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

      saveUser(account);

      return account;
    } catch (e) {
      _talker.error("Error signing in with Google: $e");
      return null;
    }
  }

  Future<void> saveUser(GoogleSignInAccount account) async {
    _isLoggedIn = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', account.toString());
    _talker.info("User saved: ${account.toString()}");
  }

  Future<String?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString('user');
    _talker.info("User retrieved: $json");

    if (json != null) {
      _isLoggedIn = true;
      return json;
    }
    return null;
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    _isLoggedIn = false;
    await _googleSignIn.signOut();

    _talker.info("User signed out.");
  }
}
