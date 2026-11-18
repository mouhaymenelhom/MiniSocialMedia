/// Textes partagés par plusieurs couches (validation, erreurs).
///
/// Pour une application multilingue, remplacer par les fichiers ARB de
/// `flutter_localizations` / `intl`.
abstract final class AppStrings {
  static const String appName = 'Mini Réseau';
  static const String unexpectedError =
      'Une erreur inattendue est survenue. Veuillez réessayer.';
  static const String requiredField = 'Ce champ est obligatoire.';
  static const String invalidEmail = 'Adresse e-mail invalide.';
  static const String passwordTooShort =
      'Le mot de passe doit contenir au moins 6 caractères.';
  static const String passwordsDoNotMatch =
      'Les mots de passe ne correspondent pas.';
}
