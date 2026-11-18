import 'package:flutter/material.dart';
import 'package:mini_reseau_social/core/constants/app_constants.dart';

/// Boîte de dialogue de modification du texte ; retourne le nouveau texte ou
/// `null` si l'utilisateur annule.
Future<String?> showEditPostDialog(BuildContext context, String initialText) {
  return showDialog<String>(
    context: context,
    builder: (context) => _EditPostDialog(initialText: initialText),
  );
}

class _EditPostDialog extends StatefulWidget {
  const _EditPostDialog({required this.initialText});

  final String initialText;

  @override
  State<_EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<_EditPostDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la publication'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 5,
        minLines: 2,
        maxLength: AppConstants.maxPostLength,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
