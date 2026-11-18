import 'package:mini_reseau_social/controllers/auth_controller.dart';
import 'package:mini_reseau_social/core/constants/app_config.dart';
import 'package:mini_reseau_social/services/ai_moderation_service.dart';
import 'package:mini_reseau_social/services/auth_service.dart';
import 'package:mini_reseau_social/services/firebase/firebase_ai_moderation_service.dart';
import 'package:mini_reseau_social/services/firebase/firebase_auth_service.dart';
import 'package:mini_reseau_social/services/firebase/firebase_friendship_service.dart';
import 'package:mini_reseau_social/services/firebase/firebase_post_service.dart';
import 'package:mini_reseau_social/services/firebase/firebase_storage_service.dart';
import 'package:mini_reseau_social/services/firebase/firebase_user_service.dart';
import 'package:mini_reseau_social/services/friendship_service.dart';
import 'package:mini_reseau_social/services/mock/mock_ai_moderation_service.dart';
import 'package:mini_reseau_social/services/mock/mock_auth_service.dart';
import 'package:mini_reseau_social/services/mock/mock_database.dart';
import 'package:mini_reseau_social/services/mock/mock_friendship_service.dart';
import 'package:mini_reseau_social/services/mock/mock_post_service.dart';
import 'package:mini_reseau_social/services/mock/mock_storage_service.dart';
import 'package:mini_reseau_social/services/mock/mock_user_service.dart';
import 'package:mini_reseau_social/services/photo_picker_service.dart';
import 'package:mini_reseau_social/services/post_service.dart';
import 'package:mini_reseau_social/services/storage_service.dart';
import 'package:mini_reseau_social/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Injection de dépendances : fournit les services (selon [AppConfig]) puis
/// les contrôleurs globaux. Les vues ne connaissent que les interfaces.
abstract final class AppProviders {
  static List<SingleChildWidget> build() => <SingleChildWidget>[
        ...(AppConfig.useFirebase ? _firebaseServices() : _mockServices()),
        Provider<PhotoPickerService>(create: (_) => ImagePickerService()),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(context.read<AuthService>()),
        ),
      ];

  static List<SingleChildWidget> _mockServices() => <SingleChildWidget>[
        Provider<MockDatabase>(create: (_) => MockDatabase()),
        Provider<AuthService>(
          create: (context) => MockAuthService(context.read<MockDatabase>()),
        ),
        Provider<UserService>(
          create: (context) => MockUserService(context.read<MockDatabase>()),
        ),
        Provider<FriendshipService>(
          create: (context) =>
              MockFriendshipService(context.read<MockDatabase>()),
        ),
        Provider<PostService>(
          create: (context) => MockPostService(context.read<MockDatabase>()),
        ),
        Provider<StorageService>(create: (_) => MockStorageService()),
        Provider<AiModerationService>(create: (_) => MockAiModerationService()),
      ];

  static List<SingleChildWidget> _firebaseServices() => <SingleChildWidget>[
        Provider<AuthService>(create: (_) => FirebaseAuthService()),
        Provider<UserService>(create: (_) => FirebaseUserService()),
        Provider<FriendshipService>(create: (_) => FirebaseFriendshipService()),
        Provider<PostService>(create: (_) => FirebasePostService()),
        Provider<StorageService>(create: (_) => FirebaseStorageService()),
        Provider<AiModerationService>(
          create: (_) => FirebaseAiModerationService(),
        ),
      ];
}
