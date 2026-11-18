import 'package:flutter/material.dart';
import 'package:mini_reseau_social/models/enums.dart';

/// Bouton d'action du profil, selon l'état de la relation (F2, F3) :
/// Ajouter, Demande envoyée, Accepter / Refuser, Amis, Modifier le profil.
class RelationshipButton extends StatelessWidget {
  const RelationshipButton({
    super.key,
    required this.status,
    required this.isBusy,
    this.onAdd,
    this.onCancel,
    this.onAccept,
    this.onDecline,
    this.onRemove,
    this.onEditProfile,
  });

  final RelationshipStatus status;
  final bool isBusy;
  final VoidCallback? onAdd;
  final VoidCallback? onCancel;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onRemove;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    VoidCallback? guard(VoidCallback? callback) => isBusy ? null : callback;

    return switch (status) {
      RelationshipStatus.self => OutlinedButton.icon(
          onPressed: onEditProfile,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Modifier le profil'),
        ),
      RelationshipStatus.none => FilledButton.icon(
          onPressed: guard(onAdd),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Ajouter'),
        ),
      RelationshipStatus.requestSent => OutlinedButton.icon(
          onPressed: guard(onCancel),
          icon: const Icon(Icons.schedule_send_outlined),
          label: const Text('Demande envoyée'),
        ),
      RelationshipStatus.requestReceived => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FilledButton(onPressed: guard(onAccept), child: const Text('Accepter')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: guard(onDecline), child: const Text('Refuser')),
          ],
        ),
      RelationshipStatus.friends => OutlinedButton.icon(
          onPressed: guard(onRemove),
          icon: const Icon(Icons.check),
          label: const Text('Amis'),
        ),
    };
  }
}
