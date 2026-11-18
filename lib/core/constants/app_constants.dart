/// Constantes fonctionnelles issues du cahier des charges.
abstract final class AppConstants {
  /// F5 : le fil est chargé par pages de 10 publications.
  static const int feedPageSize = 10;

  /// F4 : une publication contient de 1 à 4 photos.
  static const int maxPhotosPerPost = 4;

  static const int maxBioLength = 160;
  static const int maxPostLength = 500;
  static const int maxCommentLength = 300;
  static const int minPasswordLength = 6;

  /// Côté maximal (en pixels) des photos envoyées au modèle d'IA.
  static const int aiPhotoMaxSide = 512;

  /// Délai maximal d'attente de l'IA avant le statut `en_attente`.
  static const Duration aiTimeout = Duration(seconds: 15);

  static const Duration searchDebounce = Duration(milliseconds: 350);
}
