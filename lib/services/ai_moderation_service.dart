import 'package:mini_reseau_social/models/moderation_result.dart';

/// Modération et légendes automatiques (F8).
abstract interface class AiModerationService {
  /// Vérifie le texte et les photos. Lève une exception si le service est
  /// indisponible : l'appelant enregistre alors la publication « en attente ».
  Future<ModerationResult> moderate({
    required String text,
    required List<String> imagePaths,
  });

  /// Propose trois légendes courtes pour les photos.
  Future<List<String>> suggestCaptions({required List<String> imagePaths});
}
