import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/todo.dart';
import '../../services/todo_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_form_widgets.dart';

class EditTodoScreen extends StatefulWidget {
  final Todo todo;

  const EditTodoScreen({super.key, required this.todo});

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final TodoService _todoService = TodoService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _todoController;

  late bool _completed;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Todo modelinde alanın adı "todo"

    _todoController = TextEditingController(text: widget.todo.todo);

    _completed = widget.todo.completed;
  }

  Future<void> _updateTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final todoText = _todoController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      await _todoService.updateTodo(
        todoId: widget.todo.id,

        todo: todoText,

        completed: _completed,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo updated successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update todo: $e')));
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
          'Edit Todo',
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
                  text: 'Update this task or change its status.',
                  badges: [
                    AppMetaBadge(label: 'Todo ID: ${widget.todo.id}'),
                    AppMetaBadge(label: 'User ID: ${widget.todo.userId}'),
                  ],
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
                          hintText: 'Edit the task...',
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
                  label: 'Save Changes',
                  loadingLabel: 'Saving...',
                  icon: Icons.save_outlined,
                  isLoading: _isLoading,
                  onPressed: _updateTodo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
