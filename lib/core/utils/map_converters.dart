/// Convertit une valeur brute (Firestore ou JSON) en [DateTime].
///
/// Gère : `DateTime`, texte ISO 8601, millisecondes, et tout objet exposant
/// `toDate()` (le `Timestamp` de Cloud Firestore), sans dépendre du paquet.
DateTime parseDate(Object? raw) {
  if (raw is DateTime) return raw;
  if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
  if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
  if (raw != null) {
    try {
      return (raw as dynamic).toDate() as DateTime;
    } on NoSuchMethodError {
      return DateTime.now();
    }
  }
  return DateTime.now();
}
