import 'dart:async';

import 'package:mini_reseau_social/controllers/base_controller.dart';
import 'package:mini_reseau_social/core/constants/app_constants.dart';
import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/models/friend_request.dart';
import 'package:mini_reseau_social/services/friendship_service.dart';
import 'package:mini_reseau_social/services/user_service.dart';

/// Écran « Amis et demandes » : amis, demandes reçues/envoyées, recherche
/// de membres (F2, F3).
final class FriendsController extends BaseController {
  FriendsController({
    required FriendshipService friendshipService,
    required UserService userService,
    required this.currentUserId,
  })  : _friendshipService = friendshipService,
        _userService = userService {
    _subscriptions.addAll(<StreamSubscription<void>>[
      _friendshipService.watchFriends(currentUserId).listen((friends) {
        _friends = friends;
        notifyListeners();
      }),
      _friendshipService.watchReceivedRequests(currentUserId).listen((items) {
        _received = items;
        notifyListeners();
      }),
      _friendshipService.watchSentRequests(currentUserId).listen((items) {
        _sent = items;
        notifyListeners();
      }),
    ]);
  }

  final String currentUserId;
  final FriendshipService _friendshipService;
  final UserService _userService;
  final List<StreamSubscription<void>> _subscriptions =
      <StreamSubscription<void>>[];

  List<AppUser> _friends = const <AppUser>[];
  List<FriendRequest> _received = const <FriendRequest>[];
  List<FriendRequest> _sent = const <FriendRequest>[];
  List<AppUser> _searchResults = const <AppUser>[];
  String _query = '';
  bool _isSearching = false;
  Timer? _debounce;

  List<AppUser> get friends => _friends;

  List<FriendRequest> get receivedRequests => _received;

  List<FriendRequest> get sentRequests => _sent;

  List<AppUser> get searchResults => _searchResults;

  String get query => _query;

  bool get hasQuery => _query.trim().isNotEmpty;

  bool get isSearching => _isSearching;

  /// Appelée à chaque frappe ; la recherche est différée (anti-rebond).
  void onSearchChanged(String value) {
    _query = value;
    _debounce?.cancel();
    if (!hasQuery) {
      _searchResults = const <AppUser>[];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    _debounce = Timer(AppConstants.searchDebounce, _search);
  }

  void clearSearch() => onSearchChanged('');

  Future<void> _search() async {
    final currentQuery = _query;
    final success = await runGuarded(() async {
      final results = await _userService.searchByName(currentQuery);
      if (currentQuery != _query) return; // une frappe plus récente a eu lieu
      _searchResults =
          results.where((user) => user.uid != currentUserId).toList();
    }, showBusy: false);
    if (currentQuery == _query) {
      _isSearching = false;
      if (!success) _searchResults = const <AppUser>[];
      notifyListeners();
    }
  }

  Future<bool> acceptRequest(FriendRequest request) => runGuarded(
        () => _friendshipService.acceptRequest(
          fromUid: request.fromUid,
          toUid: request.toUid,
        ),
        showBusy: false,
      );

  Future<bool> declineRequest(FriendRequest request) => runGuarded(
        () => _friendshipService.declineRequest(
          fromUid: request.fromUid,
          toUid: request.toUid,
        ),
        showBusy: false,
      );

  Future<bool> cancelRequest(FriendRequest request) => runGuarded(
        () => _friendshipService.cancelRequest(
          fromUid: request.fromUid,
          toUid: request.toUid,
        ),
        showBusy: false,
      );

  Future<bool> removeFriend(AppUser friend) => runGuarded(
        () => _friendshipService.removeFriend(
          uid: currentUserId,
          friendUid: friend.uid,
        ),
        showBusy: false,
      );

  @override
  void dispose() {
    _debounce?.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
