/// Visibilité d'une publication (F4).
enum PostVisibility {
  friends('amis'),
  public('public');

  const PostVisibility(this.value);

  /// Valeur stockée dans Firestore.
  final String value;

  static PostVisibility fromValue(String? value) => values.firstWhere(
        (item) => item.value == value,
        orElse: () => friends,
      );
}

/// Statut de modération d'une publication (section 4 du cahier des charges).
enum PostStatus {
  published('publiee'),
  pending('en_attente'),
  rejected('refusee');

  const PostStatus(this.value);

  final String value;

  static PostStatus fromValue(String? value) => values.firstWhere(
        (item) => item.value == value,
        orElse: () => pending,
      );
}

/// Catégories autorisées dans la réponse JSON du modèle d'IA.
enum ModerationCategory {
  none('aucune'),
  violence('violence'),
  harassment('harcelement'),
  hate('haine'),
  sexualContent('contenu_sexuel'),
  personalData('donnees_personnelles');

  const ModerationCategory(this.value);

  final String value;

  /// Retourne `null` si [value] n'appartient pas à la liste autorisée.
  static ModerationCategory? tryParse(Object? value) {
    for (final category in values) {
      if (category.value == value) return category;
    }
    return null;
  }
}

/// Relation entre le membre connecté et un autre membre (F2, F3).
enum RelationshipStatus { self, none, friends, requestSent, requestReceived }

/// Statut d'une demande d'amitié.
enum FriendRequestStatus {
  pending('en_attente'),
  accepted('acceptee'),
  declined('refusee');

  const FriendRequestStatus(this.value);

  final String value;

  static FriendRequestStatus fromValue(String? value) => values.firstWhere(
        (item) => item.value == value,
        orElse: () => pending,
      );
}
