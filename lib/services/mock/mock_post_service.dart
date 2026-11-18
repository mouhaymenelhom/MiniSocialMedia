import 'package:mini_reseau_social/models/comment.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/post.dart';
import 'package:mini_reseau_social/services/mock/mock_database.dart';
import 'package:mini_reseau_social/services/post_service.dart';

final class MockPostService implements PostService {
  MockPostService(this._database);

  final MockDatabase _database;

  @override
  Stream<List<Post>> watchFeed({required String viewerId, required int limit}) {
    return _database.watch(
      () => _database.feedFor(viewerId).take(limit).toList(),
    );
  }

  @override
  Stream<List<Post>> watchUserPosts({
    required String authorId,
    required String viewerId,
    required int limit,
  }) {
    return _database.watch(
      () => _database
          .postsOfAuthor(authorId: authorId, viewerId: viewerId)
          .take(limit)
          .toList(),
    );
  }

  @override
  Stream<Post?> watchPost({required String postId, required String viewerId}) =>
      _database.watch(() => _database.postById(postId, viewerId));

  @override
  Future<Post> createPost({
    required String authorId,
    required String text,
    required List<String> photoUrls,
    required PostVisibility visibility,
    required PostStatus status,
  }) async {
    await _database.simulateLatency();
    return _database.addPost(
      authorId: authorId,
      text: text,
      photoUrls: photoUrls,
      visibility: visibility,
      status: status,
    );
  }

  @override
  Future<void> updatePostText({
    required String postId,
    required String text,
  }) async {
    await _database.simulateLatency();
    _database.updatePostText(postId, text);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _database.simulateLatency();
    _database.deletePost(postId);
  }

  @override
  Future<void> toggleLike({required String postId, required String uid}) async {
    _database.toggleLike(postId: postId, uid: uid);
  }

  @override
  Stream<List<Comment>> watchComments(String postId) =>
      _database.watch(() => _database.commentsOf(postId));

  @override
  Future<void> addComment({
    required String postId,
    required String authorId,
    required String text,
  }) async {
    await _database.simulateLatency();
    _database.addComment(postId: postId, authorId: authorId, text: text);
  }
}
