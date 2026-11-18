import 'package:flutter/widgets.dart';
import 'package:mini_reseau_social/controllers/base_controller.dart';
import 'package:mini_reseau_social/models/app_user.dart';
import 'package:mini_reseau_social/services/photo_picker_service.dart';
import 'package:mini_reseau_social/services/storage_service.dart';
import 'package:mini_reseau_social/services/user_service.dart';

/// Modification du profil : nom, biographie, photo (F1).
final class SettingsController extends BaseController {
  SettingsController({
    required AppUser user,
    required UserService userService,
    required StorageService storageService,
    required PhotoPickerService photoPicker,
  })  : _user = user,
        _userService = userService,
        _storageService = storageService,
        _photoPicker = photoPicker,
        nameInput = TextEditingController(text: user.name),
        bioInput = TextEditingController(text: user.bio);

  final AppUser _user;
  final UserService _userService;
  final StorageService _storageService;
  final PhotoPickerService _photoPicker;

  final TextEditingController nameInput;
  final TextEditingController bioInput;

  String? _newPhotoPath;

  /// Photo à afficher : la nouvelle sélection, sinon la photo actuelle.
  String? get photoSource => _newPhotoPath ?? _user.photoUrl;

  String get userName => _user.name;

  Future<void> pickPhoto() async {
    await runGuarded(() async {
      final paths = await _photoPicker.pickFromGallery(maxCount: 1);
      if (paths.isNotEmpty) _newPhotoPath = paths.first;
    }, showBusy: false);
  }

  Future<bool> save() {
    return runGuarded(() async {
      String? photoUrl;
      final localPath = _newPhotoPath;
      if (localPath != null) {
        photoUrl = await _storageService.uploadAvatar(
          uid: _user.uid,
          localPath: localPath,
        );
      }
      await _userService.updateProfile(
        uid: _user.uid,
        name: nameInput.text,
        bio: bioInput.text,
        photoUrl: photoUrl,
      );
    });
  }

  @override
  void dispose() {
    nameInput.dispose();
    bioInput.dispose();
    super.dispose();
  }
}
