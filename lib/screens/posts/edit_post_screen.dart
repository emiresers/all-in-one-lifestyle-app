import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_form_widgets.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final PostService _postService = PostService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _tagsController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.post.title);

    _bodyController = TextEditingController(text: widget.post.body);

    _tagsController = TextEditingController(text: widget.post.tags.join(', '));
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    setState(() {
      _isLoading = true;
    });

    try {
      await _postService.updatePost(
        postId: widget.post.id,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        tags: tags,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update post: $e')));
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
    _titleController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          'Edit Post',
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
                  text: 'Update the content of this post.',
                  badges: [AppMetaBadge(label: 'Post ID: ${widget.post.id}')],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFormSection(
                  title: 'Content',
                  children: [
                    AppLabeledField(
                      label: 'Title',
                      child: TextFormField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Give your post a title',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required.';
                          }

                          return null;
                        },
                      ),
                    ),

                    AppLabeledField(
                      label: 'Body',
                      child: TextFormField(
                        controller: _bodyController,
                        maxLines: 8,
                        minLines: 6,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                        decoration: const InputDecoration(
                          hintText: 'Write your post...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Post body is required.';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFormSection(
                  title: 'Tags',
                  children: [
                    AppLabeledField(
                      label: 'Tags',
                      helperText: 'Separate tags with commas',
                      child: TextFormField(
                        controller: _tagsController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: 'flutter, mobile, api',
                        ),
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
                  onPressed: _updatePost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
