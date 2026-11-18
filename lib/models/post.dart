import 'package:flutter/foundation.dart';
import 'package:mini_reseau_social/core/utils/map_converters.dart';
import 'package:mini_reseau_social/models/enums.dart';

/// Publication (collection `posts/{id}`).
///
/// Le nom et la photo de l'auteur sont dupliqués dans le document pour
/// afficher le fil sans lecture supplémentaire (dénormalisation).
@immutable
class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.photoUrls,
    required this.visibility,
    required this.status,
    required this.createdAt,
    this.authorPhotoUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByViewer = false,
  });

  factory Post.fromMap(Map<String, dynamic> map, {required String id}) {
    return Post(
      id: id,
      authorId: map['auteur'] as String? ?? '',
      authorName: map['auteurNom'] as String? ?? '',
      authorPhotoUrl: map['auteurPhotoUrl'] as String?,
      text: map['texte'] as String? ?? '',
      photoUrls: List<String>.from(map['photos'] as List<dynamic>? ?? const []),
      visibility: PostVisibility.fromValue(map['visibilite'] as String?),
      status: PostStatus.fromValue(map['statut'] as String?),
      likeCount: (map['nbJaime'] as num?)?.toInt() ?? 0,
      commentCount: (map['nbCommentaires'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(map['creeLe']),
    );
  }

  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final List<String> photoUrls;
  final PostVisibility visibility;
  final PostStatus status;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  /// Donnée propre au lecteur, calculée par le service (non stockée).
  final bool likedByViewer;

  bool get hasPhotos => photoUrls.isNotEmpty;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'auteur': authorId,
        'auteurNom': authorName,
        'auteurPhotoUrl': authorPhotoUrl,
        'texte': text,
        'photos': photoUrls,
        'visibilite': visibility.value,
        'statut': status.value,
        'nbJaime': likeCount,
        'nbCommentaires': commentCount,
        'creeLe': createdAt,
      };

  Post copyWith({
    String? authorName,
    String? authorPhotoUrl,
    String? text,
    PostStatus? status,
    int? likeCount,
    int? commentCount,
    bool? likedByViewer,
  }) {
    return Post(
      id: id,
      authorId: authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      text: text ?? this.text,
      photoUrls: photoUrls,
      visibility: visibility,
      status: status ?? this.status,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      likedByViewer: likedByViewer ?? this.likedByViewer,
    );
  }
}
