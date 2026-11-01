import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// Opens MainShell if the user is already logged in, otherwise Login.
/// Call this from your SplashScreen when the splash is finished:
///
///   Navigator.of(context).pushReplacement(
///     MaterialPageRoute(builder: (_) => const AuthGate()),
///   );
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthService.instance.currentUser == null
        ? const LoginScreen()
        : const MainShell();
  }
}
