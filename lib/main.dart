import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mini_reseau_social/app.dart';
import 'package:mini_reseau_social/services/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await FirebaseBootstrap.initialize();
  runApp(const MiniReseauSocialApp());
}
