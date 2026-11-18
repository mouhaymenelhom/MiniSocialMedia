import 'package:flutter/material.dart';
import 'package:mini_reseau_social/core/utils/date_formatter.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/post.dart';
import 'package:mini_reseau_social/views/extensions/enum_labels.dart';
import 'package:mini_reseau_social/views/widgets/photo_carousel.dart';
import 'package:mini_reseau_social/views/widgets/user_avatar.dart';

enum _PostMenuAction { edit, delete }

/// Carte de publication purement présentationnelle : aucune logique métier,
/// toutes les interactions remontent par des callbacks.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.isOwner,
    this.onOpen,
    this.onAuthorTap,
    this.onLikeTap,
    this.onCommentTap,
    this.onEdit,
    this.onDelete,
  });

  final Post post;
  final bool isOwner;
  final VoidCallback? onOpen;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Header(
              post: post,
              isOwner: isOwner,
              onAuthorTap: onAuthorTap,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
            if (post.status == PostStatus.pending) const _PendingBanner(),
            if (post.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(post.text),
              ),
            if (post.hasPhotos) PhotoCarousel(photoUrls: post.photoUrls),
            _ActionBar(
              post: post,
              onLikeTap: onLikeTap,
              onCommentTap: onCommentTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.post,
    required this.isOwner,
    this.onAuthorTap,
    this.onEdit,
    this.onDelete,
  });

  final Post post;
  final bool isOwner;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onAuthorTap,
      leading: UserAvatar(name: post.authorName, photoUrl: post.authorPhotoUrl),
      title: Text(post.authorName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: <Widget>[
          Flexible(child: Text(DateFormatter.relative(post.createdAt))),
          const SizedBox(width: 6),
          Icon(post.visibility.icon, size: 14, semanticLabel: post.visibility.label),
        ],
      ),
      trailing: isOwner
          ? PopupMenuButton<_PostMenuAction>(
              tooltip: 'Options de la publication',
              onSelected: (action) => switch (action) {
                _PostMenuAction.edit => onEdit?.call(),
                _PostMenuAction.delete => onDelete?.call(),
              },
              itemBuilder: (context) => const <PopupMenuEntry<_PostMenuAction>>[
                PopupMenuItem(value: _PostMenuAction.edit, child: Text('Modifier')),
                PopupMenuItem(
                  value: _PostMenuAction.delete,
                  child: Text('Supprimer'),
                ),
              ],
            )
          : null,
    );
  }
}

class _PendingBanner extends StatelessWidget {
  const _PendingBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'En attente de vérification : seul vous la voyez.',
        style: TextStyle(color: scheme.onTertiaryContainer),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.post, this.onLikeTap, this.onCommentTap});

  final Post post;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  @override
  Widget build(BuildContext context) {
    final likeColor = post.likedByViewer ? Colors.redAccent : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          TextButton.icon(
            onPressed: onLikeTap,
            icon: Icon(
              post.likedByViewer ? Icons.favorite : Icons.favorite_border,
              color: likeColor,
            ),
            label: Text('${post.likeCount}', semanticsLabel: "${post.likeCount} J'aime"),
          ),
          TextButton.icon(
            onPressed: onCommentTap,
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(
              '${post.commentCount}',
              semanticsLabel: '${post.commentCount} commentaires',
            ),
          ),
        ],
      ),
    );
  }
}
