import 'package:mini_reseau_social/core/constants/app_config.dart';

/// Point d'entrée de l'initialisation Firebase.
///
/// Étapes d'intégration (détails dans DOCUMENTATION.txt, §9) :
///  1. `flutterfire configure` génère `lib/firebase_options.dart` ;
///  2. décommenter les dépendances Firebase dans `pubspec.yaml` ;
///  3. décommenter le code ci-dessous ;
///  4. passer `AppConfig.useFirebase` à `true`.
abstract final class FirebaseBootstrap {
  static Future<void> initialize() async {
    if (!AppConfig.useFirebase) return;

    // TODO(firebase): initialiser Firebase et App Check.
    //
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    // await FirebaseAppCheck.instance.activate(
    //   androidProvider: AndroidProvider.playIntegrity, // debug en développement
    // );
  }
}
