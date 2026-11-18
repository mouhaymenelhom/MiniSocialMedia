import 'package:mini_reseau_social/services/storage_service.dart';

/// TODO(firebase) : `firebase_storage` + `flutter_image_compress`.
///
/// - Compresser chaque photo (`FlutterImageCompress.compressAndGetFile`).
/// - Chemin conseillé : `users/{uid}/posts/{uuid}.jpg` (un dossier par membre).
/// - Retourner `ref.getDownloadURL()` ; taille maximale imposée par les règles
///   de Storage.
final class FirebaseStorageService implements StorageService {
  @override
  Future<List<String>> uploadPostPhotos({
    required String uid,
    required List<String> localPaths,
  }) =>
      throw UnimplementedError();

  @override
  Future<String> uploadAvatar({
    required String uid,
    required String localPath,
  }) =>
      throw UnimplementedError();
}
