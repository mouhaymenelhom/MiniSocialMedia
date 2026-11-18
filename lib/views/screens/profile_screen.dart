import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/auth_controller.dart';
import 'package:mini_reseau_social/controllers/profile_controller.dart';
import 'package:mini_reseau_social/core/constants/app_routes.dart';
import 'package:mini_reseau_social/views/widgets/feedback.dart';
import 'package:mini_reseau_social/views/widgets/post_item.dart';
import 'package:mini_reseau_social/views/widgets/relationship_button.dart';
import 'package:mini_reseau_social/views/widgets/state_views.dart';
import 'package:mini_reseau_social/views/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

/// Profil d'un membre (F2) : photo, biographie, nombre d'amis, bouton selon
/// la relation et publications visibles par le lecteur.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileController>(
      key: ValueKey<String>(userId),
      create: (context) => ProfileController(
        postService: context.read(),
        userService: context.read(),
        friendshipService: context.read(),
        viewerId: context.read<AuthController>().currentUser!.uid,
        profileUserId: userId,
      ),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final user = controller.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.name ?? 'Profil'),
        actions: <Widget>[
          if (controller.isOwnProfile)
            IconButton(
              tooltip: 'Paramètres',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.settings),
            ),
        ],
      ),
      body: () {
        if (controller.isLoading) return const LoadingView();
        if (user == null) {
          return const EmptyView(
            icon: Icons.person_off_outlined,
            message: 'Ce membre est introuvable.',
          );
        }
        final posts = controller.posts;
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: <Widget>[
            _ProfileHeader(controller: controller),
            const Divider(),
            if (posts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: EmptyView(
                  icon: Icons.article_outlined,
                  message: 'Aucune publication à afficher.',
                ),
              ),
            for (final post in posts)
              PostItem<ProfileController>(
                key: ValueKey<String>(post.id),
                post: post,
                isAuthorTappable: false,
              ),
            if (controller.hasMorePosts)
              TextButton(
                onPressed: controller.loadMorePosts,
                child: const Text('Voir plus de publications'),
              ),
          ],
        );
      }(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.user!;
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    Future<void> run(Future<bool> action) =>
        reportIfFailed(context, controller, action);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          UserAvatar(name: user.name, photoUrl: user.photoUrl, radius: 44),
          const SizedBox(height: 12),
          Text(user.name, style: theme.textTheme.titleLarge),
          if (user.bio.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(user.bio, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 8),
          Text(
            user.friendCount > 1
                ? '${user.friendCount} amis'
                : '${user.friendCount} ami',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          RelationshipButton(
            status: controller.relationship,
            isBusy: controller.isBusy,
            onAdd: () => run(controller.sendRequest()),
            onCancel: () => run(controller.cancelRequest()),
            onAccept: () => run(controller.acceptRequest()),
            onDecline: () => run(controller.declineRequest()),
            onEditProfile: () => navigator.pushNamed(AppRoutes.settings),
            onRemove: () async {
              final confirmed = await confirmAction(
                context,
                title: 'Retirer cet ami ?',
                message: '${user.name} ne sera plus dans votre liste d\'amis.',
                confirmLabel: 'Retirer',
              );
              if (confirmed) await run(controller.removeFriend());
            },
          ),
        ],
      ),
    );
  }
}
