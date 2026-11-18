import 'package:flutter/foundation.dart';

/// Profil public d'un membre (collection `users/{uid}`).
@immutable
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    this.photoUrl,
    this.bio = '',
    this.friendCount = 0,
  });

  /// Construit un utilisateur depuis un document Firestore.
  factory AppUser.fromMap(Map<String, dynamic> map, {required String id}) {
    return AppUser(
      uid: id,
      name: map['nom'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String? ?? '',
      friendCount: (map['nbAmis'] as num?)?.toInt() ?? 0,
    );
  }

  final String uid;
  final String name;
  final String? photoUrl;
  final String bio;
  final int friendCount;

  /// Champ de recherche insensible à la casse (`nomMinuscule`).
  String get nameLowercase => name.toLowerCase();

  Map<String, dynamic> toMap() => <String, dynamic>{
        'nom': name,
        'nomMinuscule': nameLowercase,
        'photoUrl': photoUrl,
        'bio': bio,
        'nbAmis': friendCount,
      };

  AppUser copyWith({
    String? name,
    String? photoUrl,
    String? bio,
    int? friendCount,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      friendCount: friendCount ?? this.friendCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.uid == uid &&
      other.name == name &&
      other.photoUrl == photoUrl &&
      other.bio == bio &&
      other.friendCount == friendCount;

  @override
  int get hashCode => Object.hash(uid, name, photoUrl, bio, friendCount);
}
