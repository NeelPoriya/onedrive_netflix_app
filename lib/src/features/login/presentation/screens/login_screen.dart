import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/features/login/presentation/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset("assets/images/login_background.jpg",
              fit: BoxFit.cover),
        ),
        Positioned.fill(
            child: Container(
          color: Colors.black.withAlpha(100),
        )),
        Container(
          margin: const EdgeInsets.all(120.0),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Netflix',
                style: TextStyle(
                  fontSize: 45.0,
                  color: Colors.white,
                ),
              ),
              LoginForm(),
            ],
          ),
        )
      ],
    ));
  }
}
