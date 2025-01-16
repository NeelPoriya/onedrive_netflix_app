import 'package:flutter/material.dart';
import 'package:onedrive_netflix/src/features/login/presentation/widgets/login_form.dart';
import 'package:onedrive_netflix/src/utils/device_utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DeviceUtils.isTVDevice(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Error loading device information.'),
            ),
          );
        } else {
          final bool isTV = snapshot.data as bool;
          if (isTV) {
            return const LoginScreenTV();
          } else {
            return const LoginScreenMobile();
          }
        }
      },
    );
  }
}

class LoginScreenMobile extends StatelessWidget {
  const LoginScreenMobile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/login_background.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Positioned.fill(
              child: Container(
            color: Colors.black.withAlpha(200),
          )),
          Container(
            margin: const EdgeInsets.all(20.0),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ),
                Image.asset(
                  "assets/images/netflix_logos/full.png",
                  width: 300.0,
                ),
                SizedBox(height: 40.0),
                LoginForm(),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class LoginScreenTV extends StatelessWidget {
  const LoginScreenTV({
    super.key,
  });

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
