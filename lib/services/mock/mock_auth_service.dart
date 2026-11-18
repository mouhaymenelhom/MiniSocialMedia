import 'dart:async';

import 'package:mini_reseau_social/core/errors/app_exception.dart';
import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/services/auth_service.dart';
import 'package:mini_reseau_social/services/mock/mock_database.dart';

/// Authentification simulée. Comptes de test : `amal@isae.tn`,
/// `bilel@isae.tn`, `chaima@isae.tn` (mot de passe `123456`).
final class MockAuthService implements AuthService {
  MockAuthService(this._database) {
    _database.changes.listen((_) => _controller.add(currentUser));
  }

  final MockDatabase _database;
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  String? _uid;

  @override
  AppUser? get currentUser => _uid == null ? null : _database.userById(_uid!);

  @override
  Stream<AppUser?> get authStateChanges async* {
    yield currentUser;
    yield* _controller.stream.distinct();
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _database.simulateLatency();
    final uid = _database.authenticate(email, password);
    if (uid == null) throw const AppException('E-mail ou mot de passe incorrect.');
    _uid = uid;
    _controller.add(currentUser);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _database.simulateLatency();
    final user = _database.createUser(name: name, email: email, password: password);
    _uid = user.uid;
    _controller.add(currentUser);
  }

  @override
  Future<void> signOut() async {
    _uid = null;
    _controller.add(null);
  }
}
