import 'dart:async';

import 'package:mini_reseau_social/core/errors/app_exception.dart';
import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/models/comment.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/friend_request.dart';
import 'package:mini_reseau_social/models/post.dart';

/// Base de données en mémoire qui simule le backend (développement du
/// front-end sans Firebase). Les requêtes « temps réel » sont des flux qui
/// ré-émettent à chaque modification.
final class MockDatabase {
  MockDatabase() {
    _seed();
  }

  static const Duration _latency = Duration(milliseconds: 350);

  final Map<String, AppUser> _users = <String, AppUser>{};
  final Map<String, String> _uidByEmail = <String, String>{};
  final Map<String, String> _passwordByUid = <String, String>{};
  final Map<String, FriendRequest> _requests = <String, FriendRequest>{};
  final Map<String, Set<String>> _friendIds = <String, Set<String>>{};
  final Map<String, Post> _posts = <String, Post>{};
  final Map<String, Set<String>> _likes = <String, Set<String>>{};
  final Map<String, List<Comment>> _comments = <String, List<Comment>>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _idCounter = 0;

  Stream<void> get changes => _changes.stream;

  /// Émet le résultat de [query] immédiatement, puis après chaque changement.
  Stream<T> watch<T>(T Function() query) async* {
    yield query();
    await for (final _ in _changes.stream) {
      yield query();
    }
  }

  Future<void> simulateLatency() => Future<void>.delayed(_latency);

  // ------------------------------------------------------------ Utilisateurs

  AppUser? userById(String uid) {
    final user = _users[uid];
    return user?.copyWith(friendCount: _friendIds[uid]?.length ?? 0);
  }

  String? authenticate(String email, String password) {
    final uid = _uidByEmail[email.trim().toLowerCase()];
    if (uid == null || _passwordByUid[uid] != password) return null;
    return uid;
  }

  AppUser createUser({
    required String name,
    required String email,
    required String password,
  }) {
    final key = email.trim().toLowerCase();
    if (_uidByEmail.containsKey(key)) {
      throw const AppException(
        'Un compte existe déjà avec cette adresse e-mail.',
      );
    }
    final uid = _insertUser(name: name.trim(), email: key, password: password);
    _notify();
    return userById(uid)!;
  }

  List<AppUser> searchUsers(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const <AppUser>[];
    return _users.keys
        .map(userById)
        .whereType<AppUser>()
        .where((user) => user.nameLowercase.contains(needle))
        .toList();
  }

  void updateUser({
    required String uid,
    required String name,
    required String bio,
    String? photoUrl,
  }) {
    final user = _users[uid];
    if (user == null) throw const AppException('Membre introuvable.');
    _users[uid] = user.copyWith(name: name.trim(), bio: bio.trim(), photoUrl: photoUrl);
    _notify();
  }

  // ------------------------------------------------------------------ Amitiés

  bool areFriends(String a, String b) => _friendIds[a]?.contains(b) ?? false;

  RelationshipStatus relationship({
    required String viewerId,
    required String otherId,
  }) {
    if (viewerId == otherId) return RelationshipStatus.self;
    if (areFriends(viewerId, otherId)) return RelationshipStatus.friends;
    if (_requests.containsKey(FriendRequest.idFor(viewerId, otherId))) {
      return RelationshipStatus.requestSent;
    }
    if (_requests.containsKey(FriendRequest.idFor(otherId, viewerId))) {
      return RelationshipStatus.requestReceived;
    }
    return RelationshipStatus.none;
  }

  List<AppUser> friendsOf(String uid) {
    final friends = (_friendIds[uid] ?? const <String>{})
        .map(userById)
        .whereType<AppUser>()
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return friends;
  }

  List<FriendRequest> receivedRequests(String uid) => _sortedRequests(
        _requests.values.where((request) => request.toUid == uid),
      );

  List<FriendRequest> sentRequests(String uid) => _sortedRequests(
        _requests.values.where((request) => request.fromUid == uid),
      );

  void sendRequest({required String fromUid, required String toUid}) {
    if (fromUid == toUid) {
      throw const AppException('Vous ne pouvez pas vous ajouter vous-même.');
    }
    if (relationship(viewerId: fromUid, otherId: toUid) !=
        RelationshipStatus.none) {
      throw const AppException(
        'Une demande existe déjà ou vous êtes déjà amis.',
      );
    }
    final from = userById(fromUid);
    final to = userById(toUid);
    if (from == null || to == null) {
      throw const AppException('Membre introuvable.');
    }
    final request = FriendRequest(
      fromUid: fromUid,
      toUid: toUid,
      fromName: from.name,
      fromPhotoUrl: from.photoUrl,
      toName: to.name,
      toPhotoUrl: to.photoUrl,
      createdAt: DateTime.now(),
    );
    _requests[request.id] = request;
    _notify();
  }

  void deleteRequest({required String fromUid, required String toUid}) {
    _requests.remove(FriendRequest.idFor(fromUid, toUid));
    _notify();
  }

  void acceptRequest({required String fromUid, required String toUid}) {
    final removed = _requests.remove(FriendRequest.idFor(fromUid, toUid));
    if (removed == null) throw const AppException('Demande introuvable.');
    _friendIds.putIfAbsent(fromUid, () => <String>{}).add(toUid);
    _friendIds.putIfAbsent(toUid, () => <String>{}).add(fromUid);
    _notify();
  }

  void removeFriend({required String uid, required String friendUid}) {
    _friendIds[uid]?.remove(friendUid);
    _friendIds[friendUid]?.remove(uid);
    _notify();
  }

  // ------------------------------------------------------------ Publications

  List<Post> feedFor(String viewerId) => _visiblePosts(viewerId);

  List<Post> postsOfAuthor({
    required String authorId,
    required String viewerId,
  }) =>
      _visiblePosts(viewerId, authorId: authorId);

  Post? postById(String postId, String viewerId) {
    final post = _posts[postId];
    if (post == null || !_canRead(post, viewerId)) return null;
    return _hydrate(post, viewerId);
  }

  Post addPost({
    required String authorId,
    required String text,
    required List<String> photoUrls,
    required PostVisibility visibility,
    required PostStatus status,
  }) {
    final author = userById(authorId);
    if (author == null) throw const AppException('Membre introuvable.');
    final post = Post(
      id: _nextId('post'),
      authorId: authorId,
      authorName: author.name,
      authorPhotoUrl: author.photoUrl,
      text: text,
      photoUrls: photoUrls,
      visibility: visibility,
      status: status,
      createdAt: DateTime.now(),
    );
    _posts[post.id] = post;
    _notify();
    return post;
  }

  void updatePostText(String postId, String text) {
    final post = _requirePost(postId);
    _posts[postId] = post.copyWith(text: text);
    _notify();
  }

  void deletePost(String postId) {
    _posts.remove(postId);
    _likes.remove(postId);
    _comments.remove(postId);
    _notify();
  }

  void toggleLike({required String postId, required String uid}) {
    _requirePost(postId);
    final likes = _likes.putIfAbsent(postId, () => <String>{});
    if (!likes.remove(uid)) likes.add(uid);
    _notify();
  }

  List<Comment> commentsOf(String postId) =>
      List<Comment>.unmodifiable(_comments[postId] ?? const <Comment>[]);

  void addComment({
    required String postId,
    required String authorId,
    required String text,
  }) {
    _requirePost(postId);
    final author = userById(authorId);
    if (author == null) throw const AppException('Membre introuvable.');
    _comments.putIfAbsent(postId, () => <Comment>[]).add(
          Comment(
            id: _nextId('comment'),
            authorId: authorId,
            authorName: author.name,
            authorPhotoUrl: author.photoUrl,
            text: text,
            createdAt: DateTime.now(),
          ),
        );
    _notify();
  }

  // ------------------------------------------------------------------ Interne

  void _notify() => _changes.add(null);

  String _nextId(String prefix) => '${prefix}_${++_idCounter}';

  String _insertUser({
    required String name,
    required String email,
    required String password,
    String bio = '',
  }) {
    final uid = _nextId('user');
    _users[uid] = AppUser(uid: uid, name: name, bio: bio);
    _uidByEmail[email] = uid;
    _passwordByUid[uid] = password;
    return uid;
  }

  Post _requirePost(String postId) {
    final post = _posts[postId];
    if (post == null) throw const AppException('Publication introuvable.');
    return post;
  }

  List<FriendRequest> _sortedRequests(Iterable<FriendRequest> requests) =>
      requests.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  bool _canRead(Post post, String viewerId) {
    if (post.authorId == viewerId) return true;
    if (post.status != PostStatus.published) return false;
    return post.visibility == PostVisibility.public ||
        areFriends(viewerId, post.authorId);
  }

  List<Post> _visiblePosts(String viewerId, {String? authorId}) {
    return _posts.values
        .where((post) => authorId == null || post.authorId == authorId)
        .where((post) => _canRead(post, viewerId))
        .map((post) => _hydrate(post, viewerId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Post _hydrate(Post post, String viewerId) {
    final author = _users[post.authorId];
    return post.copyWith(
      authorName: author?.name,
      authorPhotoUrl: author?.photoUrl,
      likeCount: _likes[post.id]?.length ?? 0,
      commentCount: _comments[post.id]?.length ?? 0,
      likedByViewer: _likes[post.id]?.contains(viewerId) ?? false,
    );
  }

  void _seed() {
    final amal = _insertUser(
      name: 'Amal Ben Salah',
      email: 'amal@isae.tn',
      password: '123456',
      bio: 'Étudiante en informatique de gestion.',
    );
    final bilel = _insertUser(
      name: 'Bilel Trabelsi',
      email: 'bilel@isae.tn',
      password: '123456',
      bio: 'Passionné de Flutter et de football.',
    );
    final chaima = _insertUser(
      name: 'Chaima Gharbi',
      email: 'chaima@isae.tn',
      password: '123456',
    );
    _friendIds[amal] = <String>{bilel};
    _friendIds[bilel] = <String>{amal};

    final now = DateTime.now();
    for (final post in <Post>[
      Post(
        id: _nextId('post'),
        authorId: bilel,
        authorName: 'Bilel Trabelsi',
        text: 'Première démo de notre mini-projet Flutter !',
        photoUrls: const <String>[
          'https://picsum.photos/seed/isae1/800/600',
          'https://picsum.photos/seed/isae2/800/600',
        ],
        visibility: PostVisibility.friends,
        status: PostStatus.published,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Post(
        id: _nextId('post'),
        authorId: chaima,
        authorName: 'Chaima Gharbi',
        text: 'Bienvenue sur le réseau de la promotion.',
        photoUrls: const <String>[],
        visibility: PostVisibility.public,
        status: PostStatus.published,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]) {
      _posts[post.id] = post;
    }
  }
}
