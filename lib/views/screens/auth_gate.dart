import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/auth_controller.dart';
import 'package:mini_reseau_social/views/screens/home_shell.dart';
import 'package:mini_reseau_social/views/screens/login_screen.dart';
import 'package:mini_reseau_social/views/screens/splash_screen.dart';
import 'package:provider/provider.dart';

/// Aiguillage selon l'état de la session : chargement, connecté ou non.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthController, AuthStatus>(
      (controller) => controller.status,
    );
    return switch (status) {
      AuthStatus.unknown => const SplashScreen(),
      AuthStatus.authenticated => const HomeShell(),
      AuthStatus.unauthenticated => const LoginScreen(),
    };
  }
}
