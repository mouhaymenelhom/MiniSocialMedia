import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/friend_request.dart';
import 'package:mini_reseau_social/services/friendship_service.dart';

/// TODO(firebase) : collections `demandes/{de_a}` et `users/{uid}/amis/{aid}`.
///
/// - `sendRequest` : transaction qui lit les deux profils (noms dénormalisés),
///   refuse si le document `de_a` ou `a_de` existe, puis crée `de_a`.
/// - `acceptRequest` : `WriteBatch` atomique : supprimer la demande, écrire
///   `users/{a}/amis/{de}` et `users/{de}/amis/{a}`, incrémenter `nbAmis`.
/// - `watchRelationship` : combiner trois lectures (ami, `de_a`, `a_de`).
final class FirebaseFriendshipService implements FriendshipService {
  @override
  Stream<RelationshipStatus> watchRelationship({
    required String viewerId,
    required String otherId,
  }) =>
      throw UnimplementedError();

  @override
  Stream<List<AppUser>> watchFriends(String uid) => throw UnimplementedError();

  @override
  Stream<List<FriendRequest>> watchReceivedRequests(String uid) =>
      throw UnimplementedError();

  @override
  Stream<List<FriendRequest>> watchSentRequests(String uid) =>
      throw UnimplementedError();

  @override
  Future<void> sendRequest({required String fromUid, required String toUid}) =>
      throw UnimplementedError();

  @override
  Future<void> cancelRequest({
    required String fromUid,
    required String toUid,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> acceptRequest({
    required String fromUid,
    required String toUid,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> declineRequest({
    required String fromUid,
    required String toUid,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> removeFriend({required String uid, required String friendUid}) =>
      throw UnimplementedError();
}
