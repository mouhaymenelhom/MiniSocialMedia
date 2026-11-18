import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/auth_controller.dart';
import 'package:mini_reseau_social/controllers/feed_controller.dart';
import 'package:mini_reseau_social/controllers/friends_controller.dart';
import 'package:mini_reseau_social/views/screens/feed_screen.dart';
import 'package:mini_reseau_social/views/screens/friends_screen.dart';
import 'package:mini_reseau_social/views/screens/profile_screen.dart';
import 'package:provider/provider.dart';

/// Structure de l'application connectée : trois onglets (fil, amis, profil).
///
/// Les contrôleurs liés à l'utilisateur sont créés ici : ils sont détruits à
/// la déconnexion avec leurs abonnements temps réel.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthController>().currentUser!.uid;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FeedController>(
          create: (context) => FeedController(
            postService: context.read(),
            viewerId: uid,
          ),
        ),
        ChangeNotifierProvider<FriendsController>(
          create: (context) => FriendsController(
            friendshipService: context.read(),
            userService: context.read(),
            currentUserId: uid,
          ),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            const FeedScreen(),
            const FriendsScreen(),
            ProfileScreen(userId: uid),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.dynamic_feed_outlined),
              selectedIcon: Icon(Icons.dynamic_feed),
              label: 'Fil',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined),
              selectedIcon: Icon(Icons.group),
              label: 'Amis',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
