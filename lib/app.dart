import 'package:flutter/material.dart';
import 'package:mini_reseau_social/core/constants/app_strings.dart';
import 'package:mini_reseau_social/core/di/app_providers.dart';
import 'package:mini_reseau_social/core/routing/app_router.dart';
import 'package:mini_reseau_social/core/theme/app_theme.dart';
import 'package:mini_reseau_social/views/screens/auth_gate.dart';
import 'package:provider/provider.dart';

/// Racine de l'application : injection des dépendances, thème, routage.
class MiniReseauSocialApp extends StatelessWidget {
  const MiniReseauSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.build(),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const AuthGate(),
      ),
    );
  }
}
