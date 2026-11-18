/// Extensions utilitaires sur [String].
extension StringInitials on String {
  /// Initiales (deux lettres au plus) servant d'avatar de secours.
  String get initials {
    final parts = trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
