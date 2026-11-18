import 'package:flutter/material.dart';
import 'package:mini_reseau_social/core/constants/app_routes.dart';
import 'package:mini_reseau_social/views/screens/new_post_screen.dart';
import 'package:mini_reseau_social/views/screens/post_detail_screen.dart';
import 'package:mini_reseau_social/views/screens/profile_screen.dart';
import 'package:mini_reseau_social/views/screens/register_screen.dart';
import 'package:mini_reseau_social/views/screens/settings_screen.dart';

/// Table de routage : associe un nom de route à un écran.
abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.register => _page(settings, const RegisterScreen()),
      AppRoutes.newPost =>
        _page(settings, const NewPostScreen(), fullscreenDialog: true),
      AppRoutes.postDetail =>
        _page(settings, PostDetailScreen(postId: settings.arguments! as String)),
      AppRoutes.profile =>
        _page(settings, ProfileScreen(userId: settings.arguments! as String)),
      AppRoutes.settings => _page(settings, const SettingsScreen()),
      _ => null,
    };
  }

  static MaterialPageRoute<void> _page(
    RouteSettings settings,
    Widget screen, {
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute<void>(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      builder: (_) => screen,
    );
  }
}
