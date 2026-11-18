import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/auth_controller.dart';
import 'package:mini_reseau_social/controllers/post_composer_controller.dart';
import 'package:mini_reseau_social/core/constants/app_constants.dart';
import 'package:mini_reseau_social/models/enums.dart';
import 'package:mini_reseau_social/views/extensions/enum_labels.dart';
import 'package:mini_reseau_social/views/widgets/app_image.dart';
import 'package:mini_reseau_social/views/widgets/feedback.dart';
import 'package:provider/provider.dart';

/// Nouvelle publication (F4, F8) : texte, photos, visibilité, légendes de
/// l'IA et publication avec l'état « Vérification… ».
class NewPostScreen extends StatelessWidget {
  const NewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostComposerController>(
      create: (context) => PostComposerController(
        authorId: context.read<AuthController>().currentUser!.uid,
        postService: context.read(),
        storageService: context.read(),
        moderationService: context.read(),
        photoPicker: context.read(),
      ),
      child: const _NewPostView(),
    );
  }
}

class _NewPostView extends StatelessWidget {
  const _NewPostView();

  Future<void> _publish(
    BuildContext context,
    PostComposerController controller,
  ) async {
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final outcome = await controller.publish();
    switch (outcome) {
      case PublishOutcome.published:
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Publication en ligne.')),
        );
      case PublishOutcome.pending:
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Vérification indisponible : publication en attente, '
              'visible par vous seul.',
            ),
          ),
        );
      case PublishOutcome.failed:
        if (context.mounted) {
          showMessage(context, controller.errorMessage ?? 'Échec de la publication.');
        }
      case PublishOutcome.rejected || PublishOutcome.invalid:
        break; // la raison du refus est affichée dans le formulaire
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PostComposerController>();
    final theme = Theme.of(context);
    final isVerifying = controller.status == ComposerStatus.verifying;
    final isPublishing = controller.status == ComposerStatus.publishing;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle publication')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: controller.textInput,
            enabled: controller.isEditing,
            minLines: 4,
            maxLines: 8,
            maxLength: AppConstants.maxPostLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Quoi de neuf ?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          _PhotoStrip(controller: controller),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: controller.canAddPhotos
                    ? () => controller.pickFromGallery()
                    : null,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galerie'),
              ),
              OutlinedButton.icon(
                onPressed:
                    controller.canAddPhotos ? () => controller.takePhoto() : null,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Appareil photo'),
              ),
              OutlinedButton.icon(
                onPressed: controller.canSuggestCaption
                    ? () => controller.suggestCaptions()
                    : null,
                icon: controller.status == ComposerStatus.suggestingCaptions
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: const Text('Suggérer une légende'),
              ),
            ],
          ),
          if (controller.captionSuggestions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text('Légendes proposées', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final caption in controller.captionSuggestions)
                  ActionChip(
                    label: Text(caption),
                    onPressed: () => controller.applyCaption(caption),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text('Visibilité', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<PostVisibility>(
            segments: <ButtonSegment<PostVisibility>>[
              for (final visibility in PostVisibility.values)
                ButtonSegment<PostVisibility>(
                  value: visibility,
                  label: Text(visibility.label),
                  icon: Icon(visibility.icon),
                ),
            ],
            selected: <PostVisibility>{controller.visibility},
            onSelectionChanged: controller.isEditing
                ? (selection) => controller.setVisibility(selection.first)
                : null,
          ),
          if (controller.rejection != null) ...<Widget>[
            const SizedBox(height: 16),
            _RejectionCard(reason: controller.rejection!.reason),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: controller.canPublish
                ? () => _publish(context, controller)
                : null,
            child: isVerifying || isPublishing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(isVerifying ? 'Vérification…' : 'Publication…'),
                    ],
                  )
                : const Text('Publier'),
          ),
          TextButton(
            onPressed: controller.isEditing
                ? () => Navigator.of(context).pop()
                : null,
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.controller});

  final PostComposerController controller;

  @override
  Widget build(BuildContext context) {
    final paths = controller.photoPaths;
    if (paths.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final path = paths[index];
          return Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox.square(
                  dimension: 96,
                  child: AppImage(source: path),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton.filledTonal(
                  tooltip: 'Retirer la photo ${index + 1}',
                  iconSize: 16,
                  visualDensity: VisualDensity.compact,
                  onPressed:
                      controller.isEditing ? () => controller.removePhoto(path) : null,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RejectionCard extends StatelessWidget {
  const _RejectionCard({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.block, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reason.isEmpty
                  ? 'Publication refusée : elle ne respecte pas la charte.'
                  : 'Publication refusée : $reason\n'
                      'Modifiez-la ou abandonnez-la.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
