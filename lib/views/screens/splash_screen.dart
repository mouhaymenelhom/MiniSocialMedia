import 'package:flutter/material.dart';
import 'package:mini_reseau_social/views/widgets/state_views.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: LoadingView());
}
