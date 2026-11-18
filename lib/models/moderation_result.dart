import 'package:flutter/foundation.dart';
import 'package:mini_reseau_social/models/enums.dart';

/// Réponse vérifiée du modèle d'IA pour la modération d'une publication.
@immutable
class ModerationResult {
  const ModerationResult({
    required this.isPublishable,
    required this.category,
    required this.reason,
  });

  const ModerationResult.approved()
      : isPublishable = true,
        category = ModerationCategory.none,
        reason = '';

  /// Valide et convertit la réponse JSON du modèle.
  ///
  /// Lève une [FormatException] si un champ manque, a un mauvais type ou une
  /// valeur non autorisée : l'application ne fait jamais confiance à l'IA.
  factory ModerationResult.fromJson(Map<String, dynamic> json) {
    final publishable = json['publiable'];
    if (publishable is! bool) {
      throw const FormatException('Champ "publiable" absent ou non booléen.');
    }
    final category = ModerationCategory.tryParse(json['categorie']);
    if (category == null) {
      throw const FormatException('Champ "categorie" absent ou non autorisé.');
    }
    final reason = json['raison'];
    return ModerationResult(
      isPublishable: publishable,
      category: category,
      reason: reason is String ? reason : '',
    );
  }

  final bool isPublishable;
  final ModerationCategory category;
  final String reason;
}

/// Valide la réponse `{"legendes": ["…", "…", "…"]}` du second appel d'IA.
List<String> parseCaptionSuggestions(Map<String, dynamic> json) {
  final raw = json['legendes'];
  if (raw is! List<dynamic>) {
    throw const FormatException('Champ "legendes" absent ou non liste.');
  }
  final captions = raw
      .whereType<String>()
      .map((caption) => caption.trim())
      .where((caption) => caption.isNotEmpty)
      .take(3)
      .toList();
  if (captions.isEmpty) {
    throw const FormatException('Aucune légende exploitable.');
  }
  return captions;
}
