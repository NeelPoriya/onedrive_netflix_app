import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onedrive_netflix/src/features/login/services/auth.dart';
import 'package:onedrive_netflix/src/services/database_service.dart';
import 'package:onedrive_netflix/src/utils/constants.dart';
import 'package:onedrive_netflix/src/models/user.model.dart';
import 'package:talker/talker.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final DatabaseService _databaseService = DatabaseService();
  bool loading = false;
  final Talker talker = Talker();

  Future<void> fetchData() async {
    try {
      talker.info("Signing in with Google");
      setState(() {
        loading = true;
      });

      GoogleSignInAccount? account =
          await GlobalAuthService.instance.signInWithGoogle();

      if (account == null) {
        talker.info('User sign in failed');
        return;
      }

      User? user = await getUserFromDatabase(account.email);
      DateTime currentTime = DateTime.now();

      if (user == null) {
        talker.info(
            "User not found in database, creating new user for email: ${account.email}");
        User newUser = User.withDetails(
          email: account.email,
          name: account.displayName ?? '',
          photoUrl: account.photoUrl ?? '',
          createdAt: currentTime,
          updatedAt: currentTime,
          lastLogin: currentTime,
          isAdmin: false,
          status: UserStatus.pending,
        );

        _databaseService.saveData('users', newUser.toJsonWithoutId());
        talker.info('User saved ${jsonEncode(newUser.toJsonWithoutId())}');
      } else {
        talker.info('User found in database');

        user.lastLogin = currentTime;
        user.updatedAt = currentTime;
        user.photoUrl = account.photoUrl ?? '';

        _databaseService.updateData('users/${user.id}', user.toJsonWithoutId());
        talker.info('User updated ${jsonEncode(user.toJsonWithoutId())}');
      }

      // get the user from the database using email
      User? existingUser = await getUserFromDatabase(account.email);

      if (existingUser != null) {
        await GlobalAuthService.instance.saveUser(existingUser);
      }

      if (!mounted) return;
      talker.info("Sign in successful");

      context.go(Constants.homeRoute);
    } catch (e) {
      talker.info(e);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: loading
          ? null
          : () async {
              await fetchData();
            },
      icon: Icon(Icons.login),
      label: Text('Sign in with Google'),
    );
  }

  Future<User?> getUserFromDatabase(String email) async {
    final snapshot =
        await _databaseService.getDataWithFilter('users', 'email', email);

    talker.info('Getting user from database');
    if (snapshot.exists) {
      talker.info(snapshot.value);

      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      if (data.keys.length > 1) {
        talker.info('More than one user found for email $email');
      } else {
        final user = User.fromMap(data.values.first, data.keys.first);
        talker.info('User found: ${jsonEncode(user)}');
        return user;
      }
    } else {
      talker.info('User not found');
    }

    return null;
  }
}
