import 'package:intl/intl.dart';

/// Formatage des dates affichées dans l'interface.
abstract final class DateFormatter {
  /// Retourne une date relative (« il y a 5 min ») ou absolue au-delà d'une
  /// semaine. [now] est injectable pour faciliter les tests.
  static String relative(DateTime date, {DateTime? now}) {
    final difference = (now ?? DateTime.now()).difference(date);
    if (difference.inSeconds < 60) return "à l'instant";
    if (difference.inMinutes < 60) return 'il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'il y a ${difference.inHours} h';
    if (difference.inDays < 7) return 'il y a ${difference.inDays} j';
    return DateFormat.yMMMd('fr_FR').format(date);
  }
}
