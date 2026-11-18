import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mini_reseau_social/controllers/base_controller.dart';
import 'package:mini_reseau_social/core/constants/app_constants.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/models/moderation_result.dart';
import 'package:mini_reseau_social/services/ai_moderation_service.dart';
import 'package:mini_reseau_social/services/photo_picker_service.dart';
import 'package:mini_reseau_social/services/post_service.dart';
import 'package:mini_reseau_social/services/storage_service.dart';

/// Étape en cours du formulaire de publication.
enum ComposerStatus { editing, suggestingCaptions, verifying, publishing }

/// Résultat de l'action « Publier ».
enum PublishOutcome { published, pending, rejected, invalid, failed }

/// Nouvelle publication : texte, photos, visibilité, légendes et modération
/// par l'IA (F4, F8).
///
/// Flux de [publish] (section 4.1 du cahier des charges) :
/// modération -> `publiee` si acceptée, refus avec raison sinon,
/// `en_attente` si le service d'IA ne répond pas.
final class PostComposerController extends BaseController {
  PostComposerController({
    required this.authorId,
    required PostService postService,
    required StorageService storageService,
    required AiModerationService moderationService,
    required PhotoPickerService photoPicker,
  })  : _postService = postService,
        _storageService = storageService,
        _moderationService = moderationService,
        _photoPicker = photoPicker {
    textInput.addListener(notifyListeners);
  }

  final String authorId;
  final PostService _postService;
  final StorageService _storageService;
  final AiModerationService _moderationService;
  final PhotoPickerService _photoPicker;

  final TextEditingController textInput = TextEditingController();

  final List<String> _photoPaths = <String>[];
  List<String> _captionSuggestions = const <String>[];
  PostVisibility _visibility = PostVisibility.friends;
  ComposerStatus _status = ComposerStatus.editing;
  ModerationResult? _rejection;

  List<String> get photoPaths => List<String>.unmodifiable(_photoPaths);

  List<String> get captionSuggestions => _captionSuggestions;

  PostVisibility get visibility => _visibility;

  ComposerStatus get status => _status;

  ModerationResult? get rejection => _rejection;

  bool get isEditing => _status == ComposerStatus.editing;

  bool get canAddPhotos =>
      isEditing && _photoPaths.length < AppConstants.maxPhotosPerPost;

  bool get canSuggestCaption => isEditing && _photoPaths.isNotEmpty;

  bool get canPublish =>
      isEditing &&
      (textInput.text.trim().isNotEmpty || _photoPaths.isNotEmpty) &&
      textInput.text.length <= AppConstants.maxPostLength;

  void setVisibility(PostVisibility value) {
    _visibility = value;
    notifyListeners();
  }

  Future<void> pickFromGallery() async {
    final remaining = AppConstants.maxPhotosPerPost - _photoPaths.length;
    await runGuarded(() async {
      final paths = await _photoPicker.pickFromGallery(maxCount: remaining);
      _addPhotos(paths);
    }, showBusy: false);
  }

  Future<void> takePhoto() async {
    await runGuarded(() async {
      final path = await _photoPicker.takePhoto();
      if (path != null) _addPhotos(<String>[path]);
    }, showBusy: false);
  }

  void removePhoto(String path) {
    _photoPaths.remove(path);
    _captionSuggestions = const <String>[];
    notifyListeners();
  }

  void _addPhotos(List<String> paths) {
    for (final path in paths) {
      if (_photoPaths.length >= AppConstants.maxPhotosPerPost) break;
      if (!_photoPaths.contains(path)) _photoPaths.add(path);
    }
    _captionSuggestions = const <String>[];
  }

  /// « Suggérer une légende » : l'utilisateur choisit, modifie ou ignore.
  Future<void> suggestCaptions() async {
    if (!canSuggestCaption) return;
    _status = ComposerStatus.suggestingCaptions;
    notifyListeners();
    final success = await runGuarded(() async {
      _captionSuggestions = await _moderationService
          .suggestCaptions(imagePaths: _photoPaths)
          .timeout(AppConstants.aiTimeout);
    }, showBusy: false);
    if (!success) _captionSuggestions = const <String>[];
    _status = ComposerStatus.editing;
    notifyListeners();
  }

  void applyCaption(String caption) {
    textInput.text = caption;
    textInput.selection = TextSelection.collapsed(offset: caption.length);
  }

  Future<PublishOutcome> publish() async {
    if (!canPublish) return PublishOutcome.invalid;

    final text = textInput.text.trim();
    _rejection = null;
    _status = ComposerStatus.verifying;
    notifyListeners();

    var postStatus = PostStatus.published;
    try {
      final result = await _moderationService
          .moderate(text: text, imagePaths: _photoPaths)
          .timeout(AppConstants.aiTimeout);
      if (!result.isPublishable) {
        _rejection = result;
        _status = ComposerStatus.editing;
        notifyListeners();
        return PublishOutcome.rejected;
      }
    } on Exception {
      // Délai dépassé, réseau, réponse invalide : l'application reste
      // utilisable et la publication attend une nouvelle vérification.
      postStatus = PostStatus.pending;
    }

    _status = ComposerStatus.publishing;
    notifyListeners();
    final success = await runGuarded(() async {
      final urls = await _storageService.uploadPostPhotos(
        uid: authorId,
        localPaths: _photoPaths,
      );
      await _postService.createPost(
        authorId: authorId,
        text: text,
        photoUrls: urls,
        visibility: _visibility,
        status: postStatus,
      );
    }, showBusy: false);

    _status = ComposerStatus.editing;
    notifyListeners();
    if (!success) return PublishOutcome.failed;
    return postStatus == PostStatus.published
        ? PublishOutcome.published
        : PublishOutcome.pending;
  }

  @override
  void dispose() {
    textInput
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
