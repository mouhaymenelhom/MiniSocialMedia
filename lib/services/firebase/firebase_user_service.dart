import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/services/user_service.dart';

/// TODO(firebase) : collection `users/{uid}`.
///
/// - `watchUser` : `doc(uid).snapshots().map(AppUser.fromMap)`.
/// - `searchByName` : requête de préfixe sur `nomMinuscule`
///   (`where('nomMinuscule', isGreaterThanOrEqualTo: q)` et
///   `isLessThan: '$q\uf8ff'`).
/// - `updateProfile` : `doc(uid).update({...})`.
final class FirebaseUserService implements UserService {
  @override
  Stream<AppUser?> watchUser(String uid) => throw UnimplementedError();

  @override
  Future<List<AppUser>> searchByName(String query) =>
      throw UnimplementedError();

  @override
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String bio,
    String? photoUrl,
  }) =>
      throw UnimplementedError();
}
