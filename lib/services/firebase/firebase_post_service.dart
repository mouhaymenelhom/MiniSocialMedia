import 'package:mini_reseau_social/models/comment.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/post.dart';
import 'package:mini_reseau_social/services/post_service.dart';

/// TODO(firebase) : collections `posts/{id}`, `posts/{id}/jaime/{uid}`,
/// `posts/{id}/commentaires/{id}`.
///
/// - `watchFeed` : `whereIn` sur les amis (30 valeurs max par requête) ou
///   fil copié par membre ; `orderBy('creeLe', descending: true).limit(limit)`.
/// - `likedByViewer` : lire `posts/{id}/jaime/{viewerId}` pour chaque carte.
/// - `toggleLike` : transaction (document `jaime/{uid}` + compteur `nbJaime`).
/// - `deletePost` : supprimer le document ET les photos (Storage).
final class FirebasePostService implements PostService {
  @override
  Stream<List<Post>> watchFeed({required String viewerId, required int limit}) =>
      throw UnimplementedError();

  @override
  Stream<List<Post>> watchUserPosts({
    required String authorId,
    required String viewerId,
    required int limit,
  }) =>
      throw UnimplementedError();

  @override
  Stream<Post?> watchPost({required String postId, required String viewerId}) =>
      throw UnimplementedError();

  @override
  Future<Post> createPost({
    required String authorId,
    required String text,
    required List<String> photoUrls,
    required PostVisibility visibility,
    required PostStatus status,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> updatePostText({required String postId, required String text}) =>
      throw UnimplementedError();

  @override
  Future<void> deletePost(String postId) => throw UnimplementedError();

  @override
  Future<void> toggleLike({required String postId, required String uid}) =>
      throw UnimplementedError();

  @override
  Stream<List<Comment>> watchComments(String postId) =>
      throw UnimplementedError();

  @override
  Future<void> addComment({
    required String postId,
    required String authorId,
    required String text,
  }) =>
      throw UnimplementedError();
}
