import 'package:mini_reseau_social/models/app_user.dart';

/// Profils des membres (F1, F2).
abstract interface class UserService {
  Stream<AppUser?> watchUser(String uid);

  /// Recherche par nom (insensible à la casse).
  Future<List<AppUser>> searchByName(String query);

  /// [photoUrl] n'est modifiée que si elle est non nulle.
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String bio,
    String? photoUrl,
  });
}
