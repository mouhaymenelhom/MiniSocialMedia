import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/services/mock/mock_database.dart';
import 'package:mini_reseau_social/services/user_service.dart';

final class MockUserService implements UserService {
  MockUserService(this._database);

  final MockDatabase _database;

  @override
  Stream<AppUser?> watchUser(String uid) =>
      _database.watch(() => _database.userById(uid));

  @override
  Future<List<AppUser>> searchByName(String query) async {
    await _database.simulateLatency();
    return _database.searchUsers(query);
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String bio,
    String? photoUrl,
  }) async {
    await _database.simulateLatency();
    _database.updateUser(uid: uid, name: name, bio: bio, photoUrl: photoUrl);
  }
}
