import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/friend_request.dart';

/// Relations d'amitié : demandes, acceptation, refus, suppression (F2, F3).
abstract interface class FriendshipService {
  Stream<RelationshipStatus> watchRelationship({
    required String viewerId,
    required String otherId,
  });

  Stream<List<AppUser>> watchFriends(String uid);

  Stream<List<FriendRequest>> watchReceivedRequests(String uid);

  Stream<List<FriendRequest>> watchSentRequests(String uid);

  /// Lève une `AppException` si une demande existe déjà ou si les membres
  /// sont déjà amis.
  Future<void> sendRequest({required String fromUid, required String toUid});

  Future<void> cancelRequest({required String fromUid, required String toUid});

  /// Seul le destinataire peut accepter ; l'amitié est écrite des deux côtés.
  Future<void> acceptRequest({required String fromUid, required String toUid});

  Future<void> declineRequest({required String fromUid, required String toUid});

  Future<void> removeFriend({required String uid, required String friendUid});
}
