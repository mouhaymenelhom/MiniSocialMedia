import 'dart:async';

import 'package:mini_reseau_social/controllers/post_list_controller.dart';
import 'package:mini_reseau_social/core/constants/app_constants.dart';
import 'package:mini_reseau_social/core/constants/app_strings.dart';
import 'package:mini_reseau_social/models/post.dart';

/// Fil d'actualité en temps réel, chargé par pages de 10 (F5).
///
/// Principe : on écoute un flux limité à [_limit] publications ; « charger
/// plus » augmente la limite et ré-abonne le flux.
final class FeedController extends PostListController {
  FeedController({required super.postService, required super.viewerId}) {
    _subscribe();
  }

  StreamSubscription<List<Post>>? _subscription;
  List<Post> _posts = const <Post>[];
  int _limit = AppConstants.feedPageSize;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _loadError;

  List<Post> get posts => _posts;

  bool get isInitialLoading => _isInitialLoading;

  bool get isLoadingMore => _isLoadingMore;

  bool get hasMore => _hasMore;

  String? get loadError => _loadError;

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = postService
        .watchFeed(viewerId: viewerId, limit: _limit)
        .listen(_onPosts, onError: _onError);
  }

  void _onPosts(List<Post> posts) {
    _posts = posts;
    _hasMore = posts.length >= _limit;
    _isInitialLoading = false;
    _isLoadingMore = false;
    _loadError = null;
    notifyListeners();
  }

  void _onError(Object error) {
    _isInitialLoading = false;
    _isLoadingMore = false;
    _loadError = AppStrings.unexpectedError;
    notifyListeners();
  }

  void loadMore() {
    if (_isLoadingMore || _isInitialLoading || !_hasMore) return;
    _isLoadingMore = true;
    _limit += AppConstants.feedPageSize;
    notifyListeners();
    _subscribe();
  }

  /// Revient à la première page (tirer pour rafraîchir / réessayer).
  Future<void> refresh() async {
    _limit = AppConstants.feedPageSize;
    _isInitialLoading = true;
    _loadError = null;
    notifyListeners();
    _subscribe();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
