import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../services/todo_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_form_widgets.dart';

class AddTodoScreen extends StatefulWidget {
  final int userId;

  const AddTodoScreen({super.key, required this.userId});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TodoService _todoService = TodoService();

  final TextEditingController _todoController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _completed = false;
  bool _isLoading = false;

  Future<void> _addTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _todoService.addTodo(
        todo: _todoController.text.trim(),
        completed: _completed,
        userId: widget.userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Todo added successfully.')));

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not add todo: $e')));
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
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          'Add Todo',
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
                  text: 'Add a new task to your list.',
                  badges: [AppMetaBadge(label: 'User ID: ${widget.userId}')],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFormSection(
                  title: 'Task',
                  children: [
                    AppLabeledField(
                      label: 'Todo',
                      child: TextFormField(
                        controller: _todoController,
                        maxLines: 5,
                        minLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                        decoration: const InputDecoration(
                          hintText: 'What needs to be done?',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Todo cannot be empty.';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFormSection(
                  title: 'Status',
                  children: [
                    AppCompletedSwitch(
                      value: _completed,
                      onChanged: (value) {
                        setState(() {
                          _completed = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppPrimaryButton(
                  label: 'Add Todo',
                  loadingLabel: 'Adding...',
                  icon: Icons.add_task_rounded,
                  isLoading: _isLoading,
                  onPressed: _addTodo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
