import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../services/post_service.dart';
import '../../widgets/app_form_widgets.dart';

class AddPostScreen extends StatefulWidget {
  final int userId;

  const AddPostScreen({super.key, required this.userId});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final PostService _postService = PostService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _addPost() async {
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
      final result = await _postService.addPost(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        userId: widget.userId,
        tags: tags,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post published successfully. ID: ${result['id']}'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not publish post: $e')));
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
          'New Post',
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
                const AppFormIntro(
                  text:
                      'Write a title, share your thoughts and add a few tags.',
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
                  label: 'Publish Post',
                  loadingLabel: 'Publishing...',
                  icon: Icons.send_rounded,
                  isLoading: _isLoading,
                  onPressed: _addPost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
