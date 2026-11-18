import 'dart:async';

import 'package:mini_reseau_social/controllers/base_controller.dart';
import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Session de l'utilisateur (F1). Contrôleur global, fourni à la racine.
final class AuthController extends BaseController {
  AuthController(this._authService) {
    _subscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthService _authService;
  late final StreamSubscription<AppUser?> _subscription;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _currentUser;

  AuthStatus get status => _status;

  AppUser? get currentUser => _currentUser;

  void _onAuthStateChanged(AppUser? user) {
    _currentUser = user;
    _status =
        user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) {
    return runGuarded(
      () => _authService.signIn(email: email.trim(), password: password),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return runGuarded(
      () => _authService.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<void> signOut() => _authService.signOut();

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
