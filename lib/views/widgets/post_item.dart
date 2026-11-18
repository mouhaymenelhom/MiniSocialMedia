import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/post_list_controller.dart';
import 'package:mini_reseau_social/core/constants/app_routes.dart';
import 'package:mini_reseau_social/models/post.dart';
import 'package:mini_reseau_social/views/widgets/edit_post_dialog.dart';
import 'package:mini_reseau_social/views/widgets/feedback.dart';
import 'package:mini_reseau_social/views/widgets/post_card.dart';
import 'package:provider/provider.dart';

/// Relie une [PostCard] au contrôleur [T] (fil, profil ou détail) trouvé dans
/// l'arbre de widgets : navigation, « J'aime », modification, suppression.
class PostItem<T extends PostListController> extends StatelessWidget {
  const PostItem({
    super.key,
    required this.post,
    this.isDetail = false,
    this.isAuthorTappable = true,
  });

  final Post post;

  /// Dans l'écran de détail, la carte n'ouvre pas une nouvelle fois le détail.
  final bool isDetail;
  final bool isAuthorTappable;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<T>();
    final navigator = Navigator.of(context);

    return PostCard(
      post: post,
      isOwner: post.authorId == controller.viewerId,
      onOpen: isDetail
          ? null
          : () => navigator.pushNamed(AppRoutes.postDetail, arguments: post.id),
      onAuthorTap: isAuthorTappable
          ? () => navigator.pushNamed(
                AppRoutes.profile,
                arguments: post.authorId,
              )
          : null,
      onLikeTap: () =>
          reportIfFailed(context, controller, controller.toggleLike(post)),
      onCommentTap: isDetail
          ? null
          : () => navigator.pushNamed(AppRoutes.postDetail, arguments: post.id),
      onEdit: () async {
        final text = await showEditPostDialog(context, post.text);
        if (text == null || !context.mounted) return;
        await reportIfFailed(
          context,
          controller,
          controller.updatePostText(post, text),
        );
      },
      onDelete: () async {
        final confirmed = await confirmAction(
          context,
          title: 'Supprimer la publication ?',
          message: 'La publication et ses photos seront supprimées.',
          confirmLabel: 'Supprimer',
        );
        if (!confirmed || !context.mounted) return;
        final deleted = await reportIfFailed(
          context,
          controller,
          controller.deletePost(post),
        );
        if (deleted && isDetail && navigator.canPop()) navigator.pop();
      },
    );
  }
}
