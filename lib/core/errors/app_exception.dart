/// Erreur métier dont le [message] peut être affiché tel quel à l'utilisateur.
///
/// Les services la lèvent ; les contrôleurs l'interceptent et la convertissent
/// en message d'interface.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => 'AppException: $message';
}
