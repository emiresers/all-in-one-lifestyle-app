import 'package:flutter/material.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/todo.dart';

import '../../services/todo_service.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_account_actions.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/app_choice_chip.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/app_skeleton.dart';
import '../../widgets/app_screen_header.dart';

import 'add_todo_screen.dart';
import 'edit_todo_screen.dart';

class TodosScreen extends StatefulWidget {
  final int? userId;
  final ScrollController? scrollController;

  const TodosScreen({super.key, this.userId, this.scrollController});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final TodoService _todoService = TodoService();

  late Future<List<Todo>> _todosFuture;

  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    _loadTodos();
  }

  void _loadTodos() {
    if (widget.userId != null) {
      _todosFuture = _todoService.getUserTodos(widget.userId!);
    } else {
      _todosFuture = _todoService.getTodos();
    }
  }

  Future<void> _refreshTodos() async {
    setState(() {
      _loadTodos();
    });

    await _todosFuture;
  }

  List<Todo> _applyFilter(List<Todo> todos) {
    if (_selectedFilter == 'completed') {
      return todos.where((todo) => todo.completed).toList();
    }

    if (_selectedFilter == 'pending') {
      return todos.where((todo) => !todo.completed).toList();
    }

    return todos;
  }

  Future<void> _openAddTodoScreen() async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A User ID is required to add a todo.')),
      );

      return;
    }

    final result = await Navigator.push<bool>(
      context,

      AppPageRoute.to(AddTodoScreen(userId: widget.userId!)),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _loadTodos();
      });
    }
  }

  Future<void> _openEditTodoScreen(Todo todo) async {
    final result = await Navigator.push<bool>(
      context,

      AppPageRoute.to(EditTodoScreen(todo: todo)),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _loadTodos();
      });
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final shouldDelete = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Todo'),

          content: const Text('Are you sure you want to delete this todo?'),

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

    if (shouldDelete != true) {
      return;
    }

    try {
      await _todoService.deleteTodo(todo.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo deleted successfully.')),
      );

      setState(() {
        _loadTodos();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete todo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshTodos,
        edgeOffset: 12,
        child: CustomScrollView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // BAŞLIK
            SliverToBoxAdapter(
              child: AppPrimaryHeaderSurface(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.lg,
                    AppSpacing.screenH,
                    AppSpacing.lg,
                  ),
                  child: AppScreenHeader(
                    title: 'Todos',
                    subtitle: 'Keep track of what matters today',
                    foregroundColor: Colors.white,
                    action: widget.userId == null
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppHeaderButton(
                                icon: Icons.add_rounded,
                                label: 'Add',
                                onTap: _openAddTodoScreen,
                                inverted: true,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              AppAccountActions(userId: widget.userId!),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            // İLERLEME
            SliverToBoxAdapter(
              child: FutureBuilder<List<Todo>>(
                future: _todosFuture,
                builder: (context, snapshot) {
                  final todos = snapshot.data ?? const <Todo>[];

                  if (todos.isEmpty) {
                    return const SizedBox(height: AppSpacing.lg);
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.xl,
                      AppSpacing.screenH,
                      0,
                    ),
                    child: _TodoProgress(todos: todos),
                  );
                },
              ),
            ),

            // FİLTRELER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH,
                    ),
                    scrollDirection: Axis.horizontal,
                    children: [
                      AppChoiceChip(
                        label: 'All',
                        selected: _selectedFilter == 'all',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'all';
                          });
                        },
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      AppChoiceChip(
                        label: 'Completed',
                        selected: _selectedFilter == 'completed',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'completed';
                          });
                        },
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      AppChoiceChip(
                        label: 'Pending',
                        selected: _selectedFilter == 'pending',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'pending';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            // TODO LİSTESİ
            FutureBuilder<List<Todo>>(
              future: _todosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: ListCardSkeleton(cardHeight: 76),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppErrorState(
                      message: '${snapshot.error}',
                      onRetry: () {
                        setState(() {
                          _loadTodos();
                        });
                      },
                    ),
                  );
                }

                final todos = snapshot.data ?? [];

                final filteredTodos = _applyFilter(todos);

                if (filteredTodos.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      icon: _selectedFilter == 'completed'
                          ? Icons.check_circle_outline_rounded
                          : Icons.assignment_outlined,
                      title: 'No todos found',
                      subtitle: _selectedFilter == 'all'
                          ? 'Add a new task to get started.'
                          : 'Nothing here for this filter.',
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
                    key: ValueKey(_selectedFilter),
                    itemCount: filteredTodos.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.listGap),
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];

                      return _TodoCard(
                        todo: todo,
                        onEdit: () {
                          _openEditTodoScreen(todo);
                        },
                        onDelete: () {
                          _deleteTodo(todo);
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

class _TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TodoCard({
    required this.todo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Tamamlanan görev listeden silinmez, yalnızca geri çekilir.
    return AnimatedOpacity(
      opacity: todo.completed ? 0.62 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md - 2,
          AppSpacing.sm,
          AppSpacing.md - 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // İşaretlendiğinde kutucuk kısa bir zıplama yapar.
            AppBounceOnChange(
              value: todo.completed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: todo.completed
                      ? AppColors.successSoft
                      : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  todo.completed
                      ? Icons.check_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 19,
                  color: todo.completed
                      ? AppColors.success
                      : AppColors.textTertiary,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.todo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitleSmall.copyWith(
                      color: todo.completed
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppColors.textTertiary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm - 2),

                  _StatusPill(completed: todo.completed),
                ],
              ),
            ),

            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_horiz_rounded,
                size: 21,
                color: AppColors.textSecondary,
              ),
              tooltip: 'Todo actions',
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
                      Text('Delete', style: TextStyle(color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Başlığın altındaki günlük ilerleme özeti.
///
/// Sayılar listedeki gerçek görevlerden hesaplanır; ayrı bir istek yapılmaz.
class _TodoProgress extends StatelessWidget {
  final List<Todo> todos;

  const _TodoProgress({required this.todos});

  @override
  Widget build(BuildContext context) {
    final int total = todos.length;
    final int completed = todos.where((todo) => todo.completed).length;
    final double ratio = total == 0 ? 0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Today’s progress',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              Text(
                '${(ratio * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm + 2),

          Text(
            '$completed of $total completed',
            style: AppTextStyles.cardTitle,
          ),

          const SizedBox(height: AppSpacing.md),

          // Oran değiştiğinde çubuk yumuşakça büyür.
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceSecondary,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool completed;

  const _StatusPill({required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: completed ? AppColors.successSoft : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        completed ? 'Completed' : 'Pending',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: completed ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }
}
