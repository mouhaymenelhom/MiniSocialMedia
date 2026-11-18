import 'package:mini_reseau_social/controllers/base_controller.dart';
import 'package:mini_reseau_social/models/post.dart';
import 'package:mini_reseau_social/services/post_service.dart';

/// Base des contrôleurs qui affichent des publications (fil, profil, détail) :
/// factorise les actions communes (F6, F7).
abstract class PostListController extends BaseController {
  PostListController({required this.postService, required this.viewerId});

  final PostService postService;
  final String viewerId;

  Future<bool> toggleLike(Post post) => runGuarded(
        () => postService.toggleLike(postId: post.id, uid: viewerId),
        showBusy: false,
      );

  Future<bool> deletePost(Post post) => runGuarded(
        () => postService.deletePost(post.id),
        showBusy: false,
      );

  Future<bool> updatePostText(Post post, String text) => runGuarded(
        () => postService.updatePostText(postId: post.id, text: text.trim()),
        showBusy: false,
      );
}
