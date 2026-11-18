import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mini_reseau_social/controllers/post_list_controller.dart';
import 'package:mini_reseau_social/core/constants/app_constants.dart';
import 'package:mini_reseau_social/models/comment.dart';
import 'package:mini_reseau_social/models/post.dart';

/// Détail d'une publication : photos, commentaires, ajout de commentaire (F6).
final class PostDetailController extends PostListController {
  PostDetailController({
    required super.postService,
    required super.viewerId,
    required this.postId,
  }) {
    _postSubscription = postService
        .watchPost(postId: postId, viewerId: viewerId)
        .listen(_onPost);
    _commentsSubscription =
        postService.watchComments(postId).listen(_onComments);
  }

  final String postId;
  final TextEditingController commentInput = TextEditingController();

  late final StreamSubscription<Post?> _postSubscription;
  late final StreamSubscription<List<Comment>> _commentsSubscription;

  Post? _post;
  List<Comment> _comments = const <Comment>[];
  bool _isLoading = true;

  Post? get post => _post;

  List<Comment> get comments => _comments;

  bool get isLoading => _isLoading;

  /// La publication a été supprimée ou n'est plus lisible.
  bool get isUnavailable => !_isLoading && _post == null;

  void _onPost(Post? post) {
    _post = post;
    _isLoading = false;
    notifyListeners();
  }

  void _onComments(List<Comment> comments) {
    _comments = comments;
    notifyListeners();
  }

  Future<bool> addComment() async {
    final text = commentInput.text.trim();
    if (text.isEmpty || text.length > AppConstants.maxCommentLength) {
      return false;
    }
    final success = await runGuarded(
      () => postService.addComment(
        postId: postId,
        authorId: viewerId,
        text: text,
      ),
    );
    if (success) commentInput.clear();
    return success;
  }

  @override
  void dispose() {
    unawaited(_postSubscription.cancel());
    unawaited(_commentsSubscription.cancel());
    commentInput.dispose();
    super.dispose();
  }
}
