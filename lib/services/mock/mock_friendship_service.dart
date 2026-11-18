import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/friend_request.dart';
import 'package:mini_reseau_social/services/friendship_service.dart';
import 'package:mini_reseau_social/services/mock/mock_database.dart';

final class MockFriendshipService implements FriendshipService {
  MockFriendshipService(this._database);

  final MockDatabase _database;

  @override
  Stream<RelationshipStatus> watchRelationship({
    required String viewerId,
    required String otherId,
  }) {
    return _database
        .watch(
          () => _database.relationship(viewerId: viewerId, otherId: otherId),
        )
        .distinct();
  }

  @override
  Stream<List<AppUser>> watchFriends(String uid) =>
      _database.watch(() => _database.friendsOf(uid));

  @override
  Stream<List<FriendRequest>> watchReceivedRequests(String uid) =>
      _database.watch(() => _database.receivedRequests(uid));

  @override
  Stream<List<FriendRequest>> watchSentRequests(String uid) =>
      _database.watch(() => _database.sentRequests(uid));

  @override
  Future<void> sendRequest({
    required String fromUid,
    required String toUid,
  }) async {
    await _database.simulateLatency();
    _database.sendRequest(fromUid: fromUid, toUid: toUid);
  }

  @override
  Future<void> cancelRequest({
    required String fromUid,
    required String toUid,
  }) async {
    await _database.simulateLatency();
    _database.deleteRequest(fromUid: fromUid, toUid: toUid);
  }

  @override
  Future<void> acceptRequest({
    required String fromUid,
    required String toUid,
  }) async {
    await _database.simulateLatency();
    _database.acceptRequest(fromUid: fromUid, toUid: toUid);
  }

  @override
  Future<void> declineRequest({
    required String fromUid,
    required String toUid,
  }) async {
    await _database.simulateLatency();
    _database.deleteRequest(fromUid: fromUid, toUid: toUid);
  }

  @override
  Future<void> removeFriend({
    required String uid,
    required String friendUid,
  }) async {
    await _database.simulateLatency();
    _database.removeFriend(uid: uid, friendUid: friendUid);
  }
}
