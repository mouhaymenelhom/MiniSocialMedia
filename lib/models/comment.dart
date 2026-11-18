import 'package:flutter/foundation.dart';
import 'package:mini_reseau_social/core/utils/map_converters.dart';

/// Commentaire (sous-collection `posts/{id}/commentaires/{id}`).
@immutable
class Comment {
  const Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.authorPhotoUrl,
  });

  factory Comment.fromMap(Map<String, dynamic> map, {required String id}) {
    return Comment(
      id: id,
      authorId: map['auteur'] as String? ?? '',
      authorName: map['auteurNom'] as String? ?? '',
      authorPhotoUrl: map['auteurPhotoUrl'] as String?,
      text: map['texte'] as String? ?? '',
      createdAt: parseDate(map['creeLe']),
    );
  }

  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'auteur': authorId,
        'auteurNom': authorName,
        'auteurPhotoUrl': authorPhotoUrl,
        'texte': text,
        'creeLe': createdAt,
      };
}
