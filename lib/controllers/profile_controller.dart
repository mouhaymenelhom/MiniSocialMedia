import 'dart:async';

import 'package:mini_reseau_social/controllers/post_list_controller.dart';
import 'package:mini_reseau_social/core/constants/app_constants.dart';
import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/post.dart';
import 'package:mini_reseau_social/services/friendship_service.dart';
import 'package:mini_reseau_social/services/user_service.dart';

/// Profil d'un membre : informations, état de la relation et publications
/// (F2, F3). Sert aussi pour le profil du membre connecté.
final class ProfileController extends PostListController {
  ProfileController({
    required super.postService,
    required super.viewerId,
    required UserService userService,
    required FriendshipService friendshipService,
    required this.profileUserId,
  }) : _friendshipService = friendshipService {
    _subscriptions.addAll(<StreamSubscription<void>>[
      userService.watchUser(profileUserId).listen((user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      }),
      _friendshipService
          .watchRelationship(viewerId: viewerId, otherId: profileUserId)
          .listen((status) {
        _relationship = status;
        notifyListeners();
      }),
    ]);
    _subscribeToPosts();
  }

  final String profileUserId;
  final FriendshipService _friendshipService;
  final List<StreamSubscription<void>> _subscriptions =
      <StreamSubscription<void>>[];
  StreamSubscription<List<Post>>? _postsSubscription;

  AppUser? _user;
  RelationshipStatus _relationship = RelationshipStatus.none;
  List<Post> _posts = const <Post>[];
  int _limit = AppConstants.feedPageSize;
  bool _hasMorePosts = true;
  bool _isLoading = true;

  AppUser? get user => _user;

  RelationshipStatus get relationship => _relationship;

  List<Post> get posts => _posts;

  bool get hasMorePosts => _hasMorePosts;

  bool get isLoading => _isLoading;

  bool get isOwnProfile => _relationship == RelationshipStatus.self;

  void _subscribeToPosts() {
    unawaited(_postsSubscription?.cancel());
    _postsSubscription = postService
        .watchUserPosts(
          authorId: profileUserId,
          viewerId: viewerId,
          limit: _limit,
        )
        .listen((posts) {
      _posts = posts;
      _hasMorePosts = posts.length >= _limit;
      notifyListeners();
    });
  }

  void loadMorePosts() {
    if (!_hasMorePosts) return;
    _limit += AppConstants.feedPageSize;
    _subscribeToPosts();
  }

  Future<bool> sendRequest() => runGuarded(
        () => _friendshipService.sendRequest(
          fromUid: viewerId,
          toUid: profileUserId,
        ),
      );

  Future<bool> cancelRequest() => runGuarded(
        () => _friendshipService.cancelRequest(
          fromUid: viewerId,
          toUid: profileUserId,
        ),
      );

  Future<bool> acceptRequest() => runGuarded(
        () => _friendshipService.acceptRequest(
          fromUid: profileUserId,
          toUid: viewerId,
        ),
      );

  Future<bool> declineRequest() => runGuarded(
        () => _friendshipService.declineRequest(
          fromUid: profileUserId,
          toUid: viewerId,
        ),
      );

  Future<bool> removeFriend() => runGuarded(
        () => _friendshipService.removeFriend(
          uid: viewerId,
          friendUid: profileUserId,
        ),
      );

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_postsSubscription?.cancel());
    super.dispose();
  }
}
