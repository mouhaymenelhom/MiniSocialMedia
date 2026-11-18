import 'package:flutter/material.dart';
import 'package:mini_reseau_social/core/utils/image_source.dart';
import 'package:mini_reseau_social/core/utils/string_extensions.dart';

/// Avatar circulaire : photo du membre ou initiales.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 20,
    this.onTap,
  });

  final String name;
  final String? photoUrl;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final avatar = CircleAvatar(
      radius: radius,
      backgroundImage: url == null ? null : imageProviderFor(url),
      child: url == null ? Text(name.initials) : null,
    );
    return Semantics(
      label: 'Photo de $name',
      button: onTap != null,
      child: onTap == null
          ? avatar
          : GestureDetector(onTap: onTap, child: avatar),
    );
  }
}
