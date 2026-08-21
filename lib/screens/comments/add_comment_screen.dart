import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../services/comment_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_form_widgets.dart';

class AddCommentScreen extends StatefulWidget {
  final int postId;
  final int userId;

  const AddCommentScreen({
    super.key,
    required this.postId,
    required this.userId,
  });

  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  final CommentService _commentService = CommentService();

  final TextEditingController _bodyController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> _addComment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final comment = await _commentService.addComment(
        body: _bodyController.text.trim(),
        postId: widget.postId,
        userId: widget.userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment added successfully. ID: ${comment.id}'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not add comment: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          'Add Comment',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.sm,
            AppSpacing.screenH,
            AppSpacing.xxl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormIntro(
                  text: 'Share your thoughts about this post.',
                  badges: [AppMetaBadge(label: 'Post ID: ${widget.postId}')],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFormSection(
                  title: 'Your Comment',
                  children: [
                    AppLabeledField(
                      label: 'Comment',
                      child: TextFormField(
                        controller: _bodyController,
                        maxLines: 7,
                        minLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                        decoration: const InputDecoration(
                          hintText: 'Write your comment...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Comment cannot be empty.';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppPrimaryButton(
                  label: 'Add Comment',
                  loadingLabel: 'Adding...',
                  icon: Icons.add_comment_outlined,
                  isLoading: _isLoading,
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
