import 'package:flutter/material.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/post.dart';

import '../../services/post_service.dart';

import '../../widgets/app_card.dart';
import '../../widgets/app_account_actions.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_skeleton.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/app_screen_header.dart';
import '../../widgets/app_search_field.dart';

import 'add_post_screen.dart';

import 'post_detail_screen.dart';

class PostsScreen extends StatefulWidget {
  final int userId;
  final ScrollController? scrollController;

  const PostsScreen({super.key, required this.userId, this.scrollController});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final PostService _postService = PostService();

  final TextEditingController _searchController = TextEditingController();

  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();

    _loadPosts();
  }

  void _loadPosts() {
    _postsFuture = _postService.getPosts();
  }

  void _search(String query) {
    final cleanQuery = query.trim();

    setState(() {
      if (cleanQuery.isEmpty) {
        _postsFuture = _postService.getPosts();
      } else {
        _postsFuture = _postService.searchPosts(cleanQuery);
      }
    });
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _postService.getPosts();
    });

    await _postsFuture;
  }

  Future<void> _openAddPostScreen() async {
    final result = await Navigator.push<bool>(
      context,

      AppPageRoute.to(AddPostScreen(userId: widget.userId)),
    );

    if (!mounted) return;

    if (result == true) {
      _searchController.clear();

      setState(() {
        _postsFuture = _postService.getPosts();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        edgeOffset: 12,
        child: CustomScrollView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppPrimaryHeaderSurface(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        AppSpacing.lg,
                        AppSpacing.screenH,
                        0,
                      ),
                      child: AppScreenHeader(
                        title: 'Posts',
                        subtitle: 'Read and share what people write',
                        foregroundColor: Colors.white,
                        action: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppHeaderButton(
                              icon: Icons.add_rounded,
                              label: 'Add',
                              onTap: _openAddPostScreen,
                              inverted: true,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            AppAccountActions(userId: widget.userId),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        AppSpacing.lg,
                        AppSpacing.screenH,
                        0,
                      ),
                      child: AppSearchField(
                        controller: _searchController,
                        hintText: 'Search posts',
                        onChanged: _search,
                        onClear: () {
                          _searchController.clear();

                          setState(() {
                            _postsFuture = _postService.getPosts();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            // LİSTE
            FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: ListCardSkeleton(cardHeight: 168),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppErrorState(
                      message: snapshot.error.toString(),
                      onRetry: () {
                        setState(() {
                          _loadPosts();
                        });
                      },
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      icon: Icons.article_outlined,
                      title: 'No posts found',
                      subtitle: 'Try another search term.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    0,
                    AppSpacing.screenH,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverList.separated(
                    itemCount: posts.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.listGap),
                    itemBuilder: (context, index) {
                      final post = posts[index];

                      return _PostCard(
                        post: post,
                        onTap: () {
                          Navigator.push(
                            context,
                            AppPageRoute.to(PostDetailScreen(postId: post.id)),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;

  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YAZAR SATIRI
            Row(
              children: [
                _AuthorAvatar(userId: post.userId),

                const SizedBox(width: AppSpacing.sm + 2),

                Expanded(
                  child: Text(
                    'User ${post.userId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                _PostMetric(
                  icon: Icons.visibility_outlined,
                  value: _compact(post.views),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardTitle,
            ),

            const SizedBox(height: AppSpacing.sm - 2),

            Text(
              post.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySecondary,
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                // Etiketlerin ilk ikisi; kalanı sayı olarak.
                for (final String tag in post.tags.take(2)) ...[
                  Flexible(child: AppMetaBadge(label: '#$tag')),
                  const SizedBox(width: AppSpacing.sm - 2),
                ],

                if (post.tags.length > 2)
                  Text(
                    '+${post.tags.length - 2}',
                    style: AppTextStyles.metadata.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),

                const Spacer(),

                _PostMetric(
                  icon: Icons.favorite_border_rounded,
                  value: _compact(post.likes),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 4884 → 4.9K: sayaçlar kartta yer kaplamasın.
  static String _compact(int value) {
    if (value < 1000) {
      return '$value';
    }

    final double thousands = value / 1000;

    return '${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}K';
  }
}

/// Yazarı temsil eden dairesel avatar.
///
/// DummyJSON gönderilerde yazar görseli döndürmüyor; kullanıcı numarasından
/// türetilen sabit bir ton, listede yazarları birbirinden ayırt edilebilir
/// kılıyor.
class _AuthorAvatar extends StatelessWidget {
  final int userId;

  const _AuthorAvatar({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Ortak vurgu ailesinden sırayla seçilir; renkler burada tanımlı değil.
    final int slot = userId % CategoryVisual.accentSurfaces.length;

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CategoryVisual.accentSurfaces[slot],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 18,
        color: CategoryVisual.accentInks[slot],
      ),
    );
  }
}

class _PostMetric extends StatelessWidget {
  final IconData icon;

  final String value;

  const _PostMetric({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),

        const SizedBox(width: 4),

        Text(
          value,
          style: AppTextStyles.metadata.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
