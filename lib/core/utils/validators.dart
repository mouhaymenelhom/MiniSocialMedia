import 'package:mini_reseau_social/core/constants/app_constants.dart';
import 'package:mini_reseau_social/core/constants/app_strings.dart';

/// Validateurs de champs de formulaire.
///
/// Chaque méthode retourne `null` si la valeur est valide, sinon le message
/// d'erreur à afficher (contrat attendu par `FormField.validator`).
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    return _emailPattern.hasMatch(value!.trim())
        ? null
        : AppStrings.invalidEmail;
  }

  static String? password(String? value) {
    if (value == null || value.length < AppConstants.minPasswordLength) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) =>
        value == original() ? null : AppStrings.passwordsDoNotMatch;
  }

  static String? Function(String?) maxLength(int max) {
    return (value) =>
        (value?.length ?? 0) <= max ? null : 'Maximum $max caractères.';
  }
}
