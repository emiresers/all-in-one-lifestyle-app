import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/comment.dart';
import '../../services/comment_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_form_widgets.dart';

class EditCommentScreen extends StatefulWidget {
  final Comment comment;

  const EditCommentScreen({super.key, required this.comment});

  @override
  State<EditCommentScreen> createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  final CommentService _commentService = CommentService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _bodyController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _bodyController = TextEditingController(text: widget.comment.body);
  }

  Future<void> _updateComment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _commentService.updateComment(
        commentId: widget.comment.id,
        body: _bodyController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment updated successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update comment: $e')));
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
          'Edit Comment',
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
                  text: 'Update the content of your comment.',
                  badges: [
                    AppMetaBadge(label: 'Comment ID: ${widget.comment.id}'),
                    AppMetaBadge(label: 'Post ID: ${widget.comment.postId}'),
                  ],
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
                          hintText: 'Edit your comment...',
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
                  label: 'Save Changes',
                  loadingLabel: 'Saving...',
                  icon: Icons.save_outlined,
                  isLoading: _isLoading,
                  onPressed: _updateComment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
