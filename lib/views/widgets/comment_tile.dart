import 'package:flutter/material.dart';
import 'package:mini_reseau_social/core/utils/date_formatter.dart';
import 'package:mini_reseau_social/models/comment.dart';
import 'package:mini_reseau_social/views/widgets/user_avatar.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment, this.onAuthorTap});

  final Comment comment;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        name: comment.authorName,
        photoUrl: comment.authorPhotoUrl,
        radius: 16,
        onTap: onAuthorTap,
      ),
      title: Text(comment.authorName),
      subtitle: Text(comment.text),
      trailing: Text(
        DateFormatter.relative(comment.createdAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
