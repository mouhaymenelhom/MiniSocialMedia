import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mini_reseau_social/core/utils/image_source.dart';

/// Image distante (avec cache et indicateur de chargement) ou locale.
class AppImage extends StatelessWidget {
  const AppImage({super.key, required this.source, this.fit = BoxFit.cover});

  final String source;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (isRemoteImage(source)) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => const _BrokenImage(),
      );
    }
    return Image.file(
      File(source),
      fit: fit,
      errorBuilder: (_, __, ___) => const _BrokenImage(),
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}
