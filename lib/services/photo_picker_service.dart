import 'package:image_picker/image_picker.dart';

/// Accès à la galerie et à l'appareil photo.
abstract interface class PhotoPickerService {
  Future<List<String>> pickFromGallery({required int maxCount});

  Future<String?> takePhoto();
}

/// Implémentation basée sur le plugin `image_picker`.
///
/// La qualité et la largeur sont limitées dès la sélection ; la compression
/// finale avant envoi reste à la charge de `StorageService`.
final class ImagePickerService implements PhotoPickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  static const int _imageQuality = 80;
  static const double _maxWidth = 1080;

  final ImagePicker _picker;

  @override
  Future<List<String>> pickFromGallery({required int maxCount}) async {
    final files = await _picker.pickMultiImage(
      imageQuality: _imageQuality,
      maxWidth: _maxWidth,
    );
    return files.take(maxCount).map((file) => file.path).toList();
  }

  @override
  Future<String?> takePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: _imageQuality,
      maxWidth: _maxWidth,
    );
    return file?.path;
  }
}
