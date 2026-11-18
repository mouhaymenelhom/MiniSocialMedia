import 'package:flutter/foundation.dart';
import 'package:mini_reseau_social/core/utils/map_converters.dart';
import 'package:mini_reseau_social/models/enums.dart';

/// Demande d'amitié (collection `demandes/{de_a}`).
///
/// L'identifiant composé `de_a` empêche d'envoyer deux fois la même demande.
@immutable
class FriendRequest {
  const FriendRequest({
    required this.fromUid,
    required this.toUid,
    required this.fromName,
    required this.toName,
    required this.createdAt,
    this.fromPhotoUrl,
    this.toPhotoUrl,
    this.status = FriendRequestStatus.pending,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      fromUid: map['de'] as String? ?? '',
      toUid: map['a'] as String? ?? '',
      fromName: map['deNom'] as String? ?? '',
      fromPhotoUrl: map['dePhotoUrl'] as String?,
      toName: map['aNom'] as String? ?? '',
      toPhotoUrl: map['aPhotoUrl'] as String?,
      status: FriendRequestStatus.fromValue(map['statut'] as String?),
      createdAt: parseDate(map['creeLe']),
    );
  }

  final String fromUid;
  final String toUid;
  final String fromName;
  final String? fromPhotoUrl;
  final String toName;
  final String? toPhotoUrl;
  final FriendRequestStatus status;
  final DateTime createdAt;

  /// Identifiant du document Firestore.
  String get id => idFor(fromUid, toUid);

  static String idFor(String fromUid, String toUid) => '${fromUid}_$toUid';

  Map<String, dynamic> toMap() => <String, dynamic>{
        'de': fromUid,
        'a': toUid,
        'deNom': fromName,
        'dePhotoUrl': fromPhotoUrl,
        'aNom': toName,
        'aPhotoUrl': toPhotoUrl,
        'statut': status.value,
        'creeLe': createdAt,
      };
}
