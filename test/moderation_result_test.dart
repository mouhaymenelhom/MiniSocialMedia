import 'package:flutter_test/flutter_test.dart';
import 'package:mini_reseau_social/core/utils/validators.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/moderation_result.dart';

void main() {
  group('ModerationResult.fromJson', () {
    test('accepte une réponse valide', () {
      final result = ModerationResult.fromJson(<String, dynamic>{
        'publiable': false,
        'categorie': 'donnees_personnelles',
        'raison': 'Numéro de téléphone.',
      });
      expect(result.isPublishable, isFalse);
      expect(result.category, ModerationCategory.personalData);
    });

    test('rejette une catégorie non autorisée', () {
      expect(
        () => ModerationResult.fromJson(<String, dynamic>{
          'publiable': true,
          'categorie': 'inconnue',
        }),
        throwsFormatException,
      );
    });

    test('rejette un champ publiable non booléen', () {
      expect(
        () => ModerationResult.fromJson(<String, dynamic>{
          'publiable': 'oui',
          'categorie': 'aucune',
        }),
        throwsFormatException,
      );
    });
  });

  test('parseCaptionSuggestions garde trois légendes non vides', () {
    final captions = parseCaptionSuggestions(<String, dynamic>{
      'legendes': <String>['A', ' ', 'B', 'C', 'D'],
    });
    expect(captions, <String>['A', 'B', 'C']);
  });

  test('Validators.email', () {
    expect(Validators.email('a@b.tn'), isNull);
    expect(Validators.email('invalide'), isNotNull);
  });
}
