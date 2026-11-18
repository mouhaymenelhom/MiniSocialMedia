import 'package:flutter/material.dart';
import 'package:mini_reseau_social/models/enums.dart';

/// Libellés et icônes des énumérations (la couche modèle ne dépend pas de
/// Flutter : ces informations d'affichage vivent dans la vue).
extension PostVisibilityLabels on PostVisibility {
  String get label => switch (this) {
        PostVisibility.friends => 'Amis',
        PostVisibility.public => 'Public',
      };

  IconData get icon => switch (this) {
        PostVisibility.friends => Icons.group_outlined,
        PostVisibility.public => Icons.public,
      };
}
