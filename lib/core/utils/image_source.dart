import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

/// Indique si [source] est une URL distante (sinon, un chemin de fichier local).
bool isRemoteImage(String source) => source.startsWith('http');

/// Retourne le [ImageProvider] adapté à [source] (URL ou fichier local).
ImageProvider imageProviderFor(String source) {
  return isRemoteImage(source)
      ? CachedNetworkImageProvider(source) as ImageProvider
      : FileImage(File(source)) as ImageProvider;
}