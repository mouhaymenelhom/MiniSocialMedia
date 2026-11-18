import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/auth_controller.dart';
import 'package:mini_reseau_social/controllers/post_detail_controller.dart';
import 'package:mini_reseau_social/core/constants/app_constants.dart';
import 'package:mini_reseau_social/core/constants/app_routes.dart';
import 'package:mini_reseau_social/views/widgets/comment_tile.dart';
import 'package:mini_reseau_social/views/widgets/feedback.dart';
import 'package:mini_reseau_social/views/widgets/post_item.dart';
import 'package:mini_reseau_social/views/widgets/state_views.dart';
import 'package:provider/provider.dart';

/// Détail d'une publication : photos, commentaires et ajout d'un commentaire.
class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailController>(
      create: (context) => PostDetailController(
        postService: context.read(),
        viewerId: context.read<AuthController>().currentUser!.uid,
        postId: postId,
      ),
      child: const _PostDetailView(),
    );
  }
}

class _PostDetailView extends StatelessWidget {
  const _PostDetailView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PostDetailController>();
    final post = controller.post;

    return Scaffold(
      appBar: AppBar(title: const Text('Publication')),
      body: () {
        if (controller.isLoading) return const LoadingView();
        if (post == null) {
          return const EmptyView(
            icon: Icons.delete_outline,
            message: "Cette publication n'est plus disponible.",
          );
        }
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  PostItem<PostDetailController>(post: post, isDetail: true),
                  if (controller.comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Soyez le premier à commenter.')),
                    ),
                  for (final comment in controller.comments)
                    CommentTile(
                      comment: comment,
                      onAuthorTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.profile,
                        arguments: comment.authorId,
                      ),
                    ),
                ],
              ),
            ),
            const _CommentInput(),
          ],
        );
      }(),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PostDetailController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller.commentInput,
                maxLength: AppConstants.maxCommentLength,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(context, controller),
                decoration: const InputDecoration(
                  hintText: 'Ajouter un commentaire…',
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Envoyer le commentaire',
              onPressed: controller.isBusy ? null : () => _send(context, controller),
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send(BuildContext context, PostDetailController controller) async {
    if (controller.commentInput.text.trim().isEmpty) return;
    await reportIfFailed(context, controller, controller.addComment());
  }
}
