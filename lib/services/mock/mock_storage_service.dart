import 'package:mini_reseau_social/services/storage_service.dart';

/// Stockage simulé : les photos restent sur l'appareil et leur chemin local
/// tient lieu d'URL. Les widgets d'image savent afficher les deux.
final class MockStorageService implements StorageService {
  @override
  Future<List<String>> uploadPostPhotos({
    required String uid,
    required List<String> localPaths,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<String>.of(localPaths);
  }

  @override
  Future<String> uploadAvatar({
    required String uid,
    required String localPath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return localPath;
  }
}
