/// Configuration globale de l'application.
abstract final class AppConfig {
  /// Basculer sur `true` une fois les services Firebase implémentés
  /// (dossier `lib/services/firebase/`). Tant que la valeur est `false`,
  /// l'application tourne avec des services en mémoire (`lib/services/mock/`).
  static const bool useFirebase = false;
}
