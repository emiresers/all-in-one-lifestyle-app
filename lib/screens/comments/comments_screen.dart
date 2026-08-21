import 'package:flutter/material.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/comment.dart';
import '../../services/comment_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_loading_state.dart';
import '../../widgets/app_screen_header.dart';
import 'add_comment_screen.dart';
import 'edit_comment_screen.dart';

class CommentsScreen extends StatefulWidget {
  final int? postId;
  final int? userId;

  const CommentsScreen({super.key, this.postId, this.userId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommentService _commentService = CommentService();

  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    if (widget.postId != null) {
      _commentsFuture = _commentService.getCommentsByPost(widget.postId!);
    } else {
      _commentsFuture = _commentService.getComments();
    }
  }

  Future<void> _refreshComments() async {
    setState(() {
      _loadComments();
    });

    await _commentsFuture;
  }

  // YORUM EKLE
  Future<void> _openAddCommentScreen() async {
    if (widget.postId == null || widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A Post ID and User ID are required to add a comment.'),
        ),
      );

      return;
    }

    final result = await Navigator.push<bool>(
      context,
      AppPageRoute.to(
        AddCommentScreen(postId: widget.postId!, userId: widget.userId!),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _loadComments();
      });
    }
  }

  // YORUM DÜZENLE
  Future<void> _openEditCommentScreen(Comment comment) async {
    final result = await Navigator.push<bool>(
      context,
      AppPageRoute.to(EditCommentScreen(comment: comment)),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _loadComments();
      });
    }
  }

  // YORUM SİL
  Future<void> _deleteComment(Comment comment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
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
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _commentService.deleteComment(comment.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted successfully.')),
      );

      setState(() {
        _loadComments();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete comment: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canAddComment = widget.postId != null && widget.userId != null;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(toolbarHeight: 44),

      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
              ),
              child: AppScreenHeader(
                title: widget.postId != null ? 'Post Comments' : 'Comments',
                subtitle: widget.postId != null
                    ? 'Conversation around this post'
                    : 'What people are saying',
                action: canAddComment
                    ? AppHeaderButton(
                        icon: Icons.add_rounded,
                        label: 'Add',
                        onTap: _openAddCommentScreen,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Expanded(
              child: FutureBuilder<List<Comment>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState();
                  }

                  if (snapshot.hasError) {
                    return AppErrorState(
                      message: '${snapshot.error}',
                      onRetry: () {
                        setState(() {
                          _loadComments();
                        });
                      },
                    );
                  }

                  final comments = snapshot.data ?? [];

                  if (comments.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshComments,
                      child: const AppRefreshableEmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'No comments yet',
                        subtitle: 'Be the first one to share a thought.',
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshComments,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        2,
                        AppSpacing.screenH,
                        AppSpacing.xxl,
                      ),
                      itemCount: comments.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.listGap),
                      itemBuilder: (context, index) {
                        final comment = comments[index];

                        return _CommentCard(
                          comment: comment,
                          onEdit: () {
                            _openEditCommentScreen(comment);
                          },
                          onDelete: () {
                            _deleteComment(comment);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CommentCard({
    required this.comment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _initials(comment.user.fullName, comment.user.username),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user.fullName.trim().isEmpty
                          ? comment.user.username
                          : comment.user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '@${comment.user.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  size: 21,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Comment actions',
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.field),
                ),
                color: AppColors.surface,
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 19),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),

                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: AppColors.danger,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: Text(
              comment.body,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.55,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),

                const SizedBox(width: 5),

                Text(
                  '${comment.likes}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),

                const Spacer(),

                Text(
                  'Post #${comment.postId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String fullName, String username) {
    final String source = fullName.trim().isEmpty ? username : fullName.trim();

    if (source.isEmpty) {
      return '?';
    }

    final parts = source.split(' ').where((part) => part.isNotEmpty).toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
