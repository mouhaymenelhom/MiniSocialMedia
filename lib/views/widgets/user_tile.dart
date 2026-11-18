import 'package:flutter/material.dart';
import 'package:mini_reseau_social/views/widgets/user_avatar.dart';

/// Ligne de liste représentant un membre.
class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.name,
    this.photoUrl,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String name;
  final String? photoUrl;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: UserAvatar(name: name, photoUrl: photoUrl),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null || subtitle!.isEmpty
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing,
    );
  }
}
