import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/friends_controller.dart';
import 'package:mini_reseau_social/core/constants/app_routes.dart';
import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/models/friend_request.dart';
import 'package:mini_reseau_social/views/widgets/feedback.dart';
import 'package:mini_reseau_social/views/widgets/state_views.dart';
import 'package:mini_reseau_social/views/widgets/user_tile.dart';
import 'package:provider/provider.dart';

/// Amis et demandes (F2, F3) : onglets « Amis », « Reçues », « Envoyées » et
/// recherche de membres par nom.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchInput = TextEditingController();

  @override
  void dispose() {
    _searchInput.dispose();
    super.dispose();
  }

  void _openProfile(String uid) =>
      Navigator.of(context).pushNamed(AppRoutes.profile, arguments: uid);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FriendsController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Amis'),
          bottom: TabBar(
            tabs: <Widget>[
              const Tab(text: 'Amis'),
              Tab(text: 'Reçues (${controller.receivedRequests.length})'),
              Tab(text: 'Envoyées (${controller.sentRequests.length})'),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchInput,
                onChanged: controller.onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Rechercher un membre',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.hasQuery
                      ? IconButton(
                          tooltip: 'Effacer la recherche',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchInput.clear();
                            controller.clearSearch();
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: controller.hasQuery
                  ? _SearchResults(
                      controller: controller,
                      onOpenProfile: _openProfile,
                    )
                  : TabBarView(
                      children: <Widget>[
                        _FriendsList(
                          friends: controller.friends,
                          onOpenProfile: _openProfile,
                        ),
                        _ReceivedList(
                          requests: controller.receivedRequests,
                          onOpenProfile: _openProfile,
                        ),
                        _SentList(
                          requests: controller.sentRequests,
                          onOpenProfile: _openProfile,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.controller, required this.onOpenProfile});

  final FriendsController controller;
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    if (controller.isSearching) return const LoadingView();
    if (controller.searchResults.isEmpty) {
      return const EmptyView(
        icon: Icons.search_off,
        message: 'Aucun membre trouvé.',
      );
    }
    return ListView(
      children: <Widget>[
        for (final user in controller.searchResults)
          UserTile(
            name: user.name,
            photoUrl: user.photoUrl,
            subtitle: user.bio,
            onTap: () => onOpenProfile(user.uid),
          ),
      ],
    );
  }
}

enum _FriendMenuAction { remove }

class _FriendsList extends StatelessWidget {
  const _FriendsList({required this.friends, required this.onOpenProfile});

  final List<AppUser> friends;
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const EmptyView(
        icon: Icons.group_outlined,
        message: "Vous n'avez pas encore d'amis.\nUtilisez la recherche.",
      );
    }
    final controller = context.read<FriendsController>();
    return ListView(
      children: <Widget>[
        for (final friend in friends)
          UserTile(
            name: friend.name,
            photoUrl: friend.photoUrl,
            subtitle: friend.bio,
            onTap: () => onOpenProfile(friend.uid),
            trailing: PopupMenuButton<_FriendMenuAction>(
              tooltip: 'Options',
              onSelected: (_) async {
                final confirmed = await confirmAction(
                  context,
                  title: 'Retirer cet ami ?',
                  message: '${friend.name} ne sera plus dans votre liste d\'amis.',
                  confirmLabel: 'Retirer',
                );
                if (confirmed && context.mounted) {
                  await reportIfFailed(
                    context,
                    controller,
                    controller.removeFriend(friend),
                  );
                }
              },
              itemBuilder: (context) => const <PopupMenuEntry<_FriendMenuAction>>[
                PopupMenuItem(
                  value: _FriendMenuAction.remove,
                  child: Text('Retirer des amis'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReceivedList extends StatelessWidget {
  const _ReceivedList({required this.requests, required this.onOpenProfile});

  final List<FriendRequest> requests;
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const EmptyView(
        icon: Icons.mark_email_unread_outlined,
        message: 'Aucune demande reçue.',
      );
    }
    final controller = context.read<FriendsController>();
    return ListView(
      children: <Widget>[
        for (final request in requests)
          UserTile(
            name: request.fromName,
            photoUrl: request.fromPhotoUrl,
            onTap: () => onOpenProfile(request.fromUid),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  tooltip: 'Accepter',
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () => reportIfFailed(
                    context,
                    controller,
                    controller.acceptRequest(request),
                  ),
                ),
                IconButton(
                  tooltip: 'Refuser',
                  icon: const Icon(Icons.cancel_outlined),
                  onPressed: () => reportIfFailed(
                    context,
                    controller,
                    controller.declineRequest(request),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SentList extends StatelessWidget {
  const _SentList({required this.requests, required this.onOpenProfile});

  final List<FriendRequest> requests;
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const EmptyView(
        icon: Icons.send_outlined,
        message: 'Aucune demande envoyée.',
      );
    }
    final controller = context.read<FriendsController>();
    return ListView(
      children: <Widget>[
        for (final request in requests)
          UserTile(
            name: request.toName,
            photoUrl: request.toPhotoUrl,
            onTap: () => onOpenProfile(request.toUid),
            trailing: TextButton(
              onPressed: () => reportIfFailed(
                context,
                controller,
                controller.cancelRequest(request),
              ),
              child: const Text('Annuler'),
            ),
          ),
      ],
    );
  }
}
