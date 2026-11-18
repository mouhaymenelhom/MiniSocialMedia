import 'package:mini_reseau_social/models/comment.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/post.dart';

/// Publications, fil d'actualité, « J'aime » et commentaires (F4 à F7).
abstract interface class PostService {
  /// Publications visibles par [viewerId] (amis, publiques, siennes),
  /// de la plus récente à la plus ancienne, limitées à [limit].
  Stream<List<Post>> watchFeed({required String viewerId, required int limit});

  Stream<List<Post>> watchUserPosts({
    required String authorId,
    required String viewerId,
    required int limit,
  });

  /// Émet `null` si la publication n'existe plus ou n'est pas lisible.
  Stream<Post?> watchPost({required String postId, required String viewerId});

  Future<Post> createPost({
    required String authorId,
    required String text,
    required List<String> photoUrls,
    required PostVisibility visibility,
    required PostStatus status,
  });

  Future<void> updatePostText({required String postId, required String text});

  /// Supprime la publication et ses photos.
  Future<void> deletePost(String postId);

  /// Ajoute le « J'aime » du membre, ou le retire s'il existe déjà.
  Future<void> toggleLike({required String postId, required String uid});

  Stream<List<Comment>> watchComments(String postId);

  Future<void> addComment({
    required String postId,
    required String authorId,
    required String text,
  });
}
