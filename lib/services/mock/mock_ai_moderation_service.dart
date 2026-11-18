import 'dart:async';

import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/moderation_result.dart';
import 'package:mini_reseau_social/services/ai_moderation_service.dart';

/// Modération simulée par règles simples.
///
/// - un numéro de téléphone (8 chiffres ou plus) est refusé ;
/// - quelques mots-clés déclenchent les autres catégories ;
/// - le texte `#ia-indisponible` simule une panne (statut `en_attente`).
final class MockAiModerationService implements AiModerationService {
  static final RegExp _phonePattern = RegExp(r'(?:\+?\d[\s.-]?){8,}');

  static const Map<ModerationCategory, List<String>> _keywords =
      <ModerationCategory, List<String>>{
    ModerationCategory.violence: <String>['tuer', 'frapper'],
    ModerationCategory.harassment: <String>['idiot', 'nul à chier'],
    ModerationCategory.hate: <String>['haine'],
  };

  @override
  Future<ModerationResult> moderate({
    required String text,
    required List<String> imagePaths,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final lowerText = text.toLowerCase();

    if (lowerText.contains('#ia-indisponible')) {
      throw TimeoutException('Service de modération indisponible.');
    }
    if (_phonePattern.hasMatch(text)) {
      return const ModerationResult(
        isPublishable: false,
        category: ModerationCategory.personalData,
        reason: 'Le texte contient un numéro de téléphone.',
      );
    }
    for (final MapEntry(:key, :value) in _keywords.entries) {
      if (value.any(lowerText.contains)) {
        return ModerationResult(
          isPublishable: false,
          category: key,
          reason: 'Le texte ne respecte pas la charte de la communauté.',
        );
      }
    }
    return const ModerationResult.approved();
  }

  @override
  Future<List<String>> suggestCaptions({required List<String> imagePaths}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return const <String>[
      'Un beau moment partagé',
      'Des souvenirs à garder',
      'Simplement heureux',
    ];
  }
}
