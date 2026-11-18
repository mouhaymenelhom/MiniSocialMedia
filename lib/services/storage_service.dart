/// Envoi des photos vers le stockage en ligne (F1, F4).
abstract interface class StorageService {
  /// Compresse puis envoie les photos ; retourne leurs URL, dans le même ordre.
  Future<List<String>> uploadPostPhotos({
    required String uid,
    required List<String> localPaths,
  });

  Future<String> uploadAvatar({required String uid, required String localPath});
}
