import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/base_controller.dart';
import 'package:mini_reseau_social/core/constants/app_strings.dart';

/// Attend [result] et affiche l'erreur du [controller] en cas d'échec.
Future<bool> reportIfFailed(
  BuildContext context,
  BaseController controller,
  Future<bool> result,
) async {
  final success = await result;
  if (!success && context.mounted) {
    showMessage(context, controller.errorMessage ?? AppStrings.unexpectedError);
  }
  return success;
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Demande une confirmation ; `true` si l'utilisateur valide.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmer',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
