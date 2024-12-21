import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  DatabaseReference ref = FirebaseDatabase.instance.ref('users/123');

  Future<void> fetchData() async {
    try {
      print("Fetching data");

      GoogleSignInAccount? user = await GlobalAuthService.instance.signInWithGoogle();

      if (user == null) {
        print('User sign in failed');
        return;
      }

      if (!mounted) return;
      context.go(Constants.homeRoute);

      print("Data fetched");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () async {
        await fetchData();
      },
      icon: const Icon(Icons.login_rounded),
      label: const Text('Login with Google'),
    );
  }
}
