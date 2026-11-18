import 'package:mini_reseau_social/models/moderation_result.dart';
import 'package:mini_reseau_social/services/ai_moderation_service.dart';

/// TODO(firebase) : `firebase_ai` (Firebase AI Logic, Gemini Developer API)
/// protégé par App Check. Aucune clé d'API dans le code.
///
/// - Réduire les photos à `AppConstants.aiPhotoMaxSide` pixels avant l'appel.
/// - Imposer une réponse JSON (`GenerationConfig(responseMimeType:
///   'application/json')`) puis `jsonDecode` ->
///   `ModerationResult.fromJson` / `parseCaptionSuggestions` (validation).
/// - Ne jamais attraper silencieusement les erreurs : le contrôleur gère le
///   statut `en_attente` et le délai (`AppConstants.aiTimeout`).
final class FirebaseAiModerationService implements AiModerationService {
  @override
  Future<ModerationResult> moderate({
    required String text,
    required List<String> imagePaths,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<String>> suggestCaptions({required List<String> imagePaths}) =>
      throw UnimplementedError();
}
