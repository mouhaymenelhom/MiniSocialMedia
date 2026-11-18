import 'package:flutter/material.dart';
import 'package:mini_reseau_social/controllers/feed_controller.dart';
import 'package:mini_reseau_social/core/constants/app_routes.dart';
import 'package:mini_reseau_social/core/constants/app_strings.dart';
import 'package:mini_reseau_social/views/widgets/post_item.dart';
import 'package:mini_reseau_social/views/widgets/state_views.dart';
import 'package:provider/provider.dart';

/// Fil d'actualité (F5) : publications des amis et publiques, en temps réel,
/// chargées par pages de 10 au fil du défilement.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const double _loadMoreThreshold = 400;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      context.read<FeedController>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FeedController>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nouvelle publication',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.newPost),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(controller),
    );
  }

  Widget _buildBody(FeedController controller) {
    if (controller.isInitialLoading) return const LoadingView();
    if (controller.loadError != null) {
      return ErrorView(message: controller.loadError!, onRetry: controller.refresh);
    }
    final posts = controller.posts;
    if (posts.isEmpty) {
      return const EmptyView(
        icon: Icons.photo_library_outlined,
        message: 'Aucune publication pour le moment.\n'
            'Ajoutez des amis ou publiez votre premier statut.',
      );
    }
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: posts.length + (controller.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return PostItem<FeedController>(
            key: ValueKey<String>(posts[index].id),
            post: posts[index],
          );
        },
      ),
    );
  }
}
