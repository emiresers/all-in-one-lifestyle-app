import 'package:flutter/material.dart';

import '../../core/app_page_route.dart';
import '../comments/comments_screen.dart';

import '../../core/theme/app_colors.dart';
import '../../models/post.dart';

import '../../services/post_service.dart';

import 'edit_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostService _postService = PostService();

  late Future<Post> _postFuture;

  @override
  void initState() {
    super.initState();

    _loadPost();
  }

  void _loadPost() {
    _postFuture = _postService.getPost(widget.postId);
  }

  Future<void> _openEditScreen(Post post) async {
    final result = await Navigator.push<bool>(
      context,

      AppPageRoute.to(EditPostScreen(post: post)),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _loadPost();
      });
    }
  }

  Future<void> _deletePost(Post post) async {
    final shouldDelete = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            'Postu Sil',

            style: TextStyle(fontWeight: FontWeight.w700),
          ),

          content: const Text('Are you sure you want to delete this post?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _postService.deletePost(post.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Post silinemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Post>(
      future: _postFuture,

      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            title: const Text(
              'Post Detail',

              style: TextStyle(fontWeight: FontWeight.w700),
            ),

            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),

                tooltip: 'Edit Post',

                onPressed: snapshot.hasData
                    ? () {
                        _openEditScreen(snapshot.data!);
                      }
                    : null,
              ),

              IconButton(
                icon: const Icon(Icons.delete_outline),

                tooltip: 'Postu Sil',

                onPressed: snapshot.hasData
                    ? () {
                        _deletePost(snapshot.data!);
                      }
                    : null,
              ),

              const SizedBox(width: 8),
            ],
          ),

          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<Post> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return _PostDetailError(
        message: snapshot.error.toString(),

        onRetry: () {
          setState(() {
            _loadPost();
          });
        },
      );
    }

    if (!snapshot.hasData) {
      return const Center(child: Text('Post not found.'));
    }

    final post = snapshot.data!;

    return SafeArea(
      top: false,

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // USER / POST META

            Row(
              children: [
                Container(
                  width: 48,

                  height: 48,

                  decoration: BoxDecoration(
                    color: AppColors.surface,

                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(color: AppColors.border),
                  ),

                  child: const Icon(Icons.person_outline_rounded),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'User ${post.userId}',

                        style: const TextStyle(
                          fontSize: 15,

                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Post #${post.id}',

                        style: TextStyle(
                          fontSize: 13,

                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,

                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.surface,

                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(color: AppColors.border),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,

                        size: 16,

                        color: AppColors.textSecondary,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        '${post.views}',

                        style: TextStyle(
                          fontSize: 12,

                          fontWeight: FontWeight.w600,

                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // TITLE
            Text(
              post.title,

              style: const TextStyle(
                fontSize: 30,

                fontWeight: FontWeight.w800,

                letterSpacing: -0.8,

                height: 1.15,
              ),
            ),

            const SizedBox(height: 22),

            // CONTENT CARD
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.surface,

                borderRadius: BorderRadius.circular(22),

                border: Border.all(color: AppColors.border),

                boxShadow: AppColors.softShadow,
              ),

              child: Text(
                post.body,

                style: TextStyle(
                  fontSize: 15.5,

                  height: 1.7,

                  color: AppColors.textPrimary,
                ),
              ),
            ),

            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 22),

              const Text(
                'Tags',

                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,

                runSpacing: 8,

                children: post.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,

                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          '#$tag',

                          style: TextStyle(
                            fontSize: 12,

                            fontWeight: FontWeight.w600,

                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 26),

            // STATS
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.visibility_outlined,

                    label: 'Views',

                    value: '${post.views}',
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _StatCard(
                    icon: Icons.thumb_up_alt_outlined,

                    label: 'Likes',

                    value: '${post.likes}',
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _StatCard(
                    icon: Icons.thumb_down_alt_outlined,

                    label: 'Dislikes',

                    value: '${post.dislikes}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // COMMENTS BUTTON
            SizedBox(
              width: double.infinity,

              height: 56,

              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,

                    AppPageRoute.to(
                      CommentsScreen(postId: post.id, userId: post.userId),
                    ),
                  );
                },

                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                icon: const Icon(Icons.comment_outlined),

                label: const Text(
                  'View Comments',

                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;

  final String label;

  final String value;

  const _StatCard({
    required this.icon,

    required this.label,

    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),

          const SizedBox(height: 7),

          Text(
            value,

            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 3),

          Text(
            label,

            style: TextStyle(
              fontSize: 11.5,

              color: AppColors.textTertiary,

              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostDetailError extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const _PostDetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.error_outline_rounded, size: 52),

            const SizedBox(height: 16),

            const Text(
              'Post couldn’t be loaded',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              message,

              textAlign: TextAlign.center,

              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
