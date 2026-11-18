import 'package:mini_reseau_social/models/app_user.dart';

/// Authentification et session (F1).
abstract interface class AuthService {
  /// Utilisateur connecté, ou `null`.
  AppUser? get currentUser;

  /// Émet l'utilisateur à chaque changement de session ou de profil.
  Stream<AppUser?> get authStateChanges;

  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}
