import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/services/auth_service.dart';

/// TODO(firebase) : implémenter avec `firebase_auth` + `cloud_firestore`.
///
/// - `signIn` / `register` : `FirebaseAuth.instance.signInWithEmailAndPassword`
///   / `createUserWithEmailAndPassword`, puis créer `users/{uid}` à l'inscription.
/// - `authStateChanges` : `FirebaseAuth.instance.authStateChanges()` combiné
///   (`asyncExpand`) avec un `snapshots()` du document `users/{uid}`.
/// - Convertir les `FirebaseAuthException` en `AppException` (messages français).
final class FirebaseAuthService implements AuthService {
  @override
  AppUser? get currentUser => throw UnimplementedError();

  @override
  Stream<AppUser?> get authStateChanges => throw UnimplementedError();

  @override
  Future<void> signIn({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}
