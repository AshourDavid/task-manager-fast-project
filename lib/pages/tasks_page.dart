import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/app/theme/dark_theme.dart';
import 'package:task_manager/models/enums/category.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/pages/edit_task_page.dart';
import 'package:task_manager/providers/tasks_provider.dart';

enum TaskFilter { all, time, priority }

final filterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

final filteredTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final filter = ref.watch(filterProvider);

  return tasksAsync.whenData((tasks) {
    List<TaskModel> sortedList = [...tasks];
    switch (filter) {
      case TaskFilter.time:
        sortedList.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TaskFilter.priority:
        sortedList.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case TaskFilter.all:
      default:
        break;
    }
    return sortedList;
  });
});

class TaskFlowPage extends ConsumerWidget {
  const TaskFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(filterProvider);
    final theme = Theme.of(context);
    final kinetic = theme.extension<KineticEffects>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(
          Icons.grid_view_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          'TaskFlow',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.outlineVariant,
              child: const Icon(Icons.person, size: 20),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Editorial Headline
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.displayLarge,
                  children: [
                    const TextSpan(text: "Focus on your\n"),
                    TextSpan(
                      text: "intentions.",
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filters Section
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _FilterChip(
                    label: "All",
                    isSelected: currentFilter == TaskFilter.all,
                    onTap: () => ref.read(filterProvider.notifier).state =
                        TaskFilter.all,
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    label: "Time",
                    isSelected: currentFilter == TaskFilter.time,
                    onTap: () => ref.read(filterProvider.notifier).state =
                        TaskFilter.time,
                  ),
                  const SizedBox(width: 12),
                  _FilterChip(
                    label: "Priority",
                    isSelected: currentFilter == TaskFilter.priority,
                    onTap: () => ref.read(filterProvider.notifier).state =
                        TaskFilter.priority,
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 16)),

          // Task List Grid
          tasksAsync.when(
            data: (tasks) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _TaskTile(task: tasks[index]),
                  childCount: tasks.length,
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverToBoxAdapter(child: Text('Error: $err')),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Necessary for keyboard handling
            backgroundColor: Colors.transparent,
            builder: (context) =>
                SingleChildScrollView(child: const AddTaskModal()),
          );
        }, // Add task logic
        backgroundColor: theme.colorScheme.primaryContainer,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  final TaskModel task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.category.name.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(tasksProvider.notifier).toggle(task),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.isDone
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                    ),
                    color: task.isDone
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: task.isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.black)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                final theme = Theme.of(context);
                final kinetic = theme.extension<KineticEffects>();
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.8),
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: kinetic?.ghostBorder ?? Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Header Banner Image
                            Stack(
                              children: [
                                Container(
                                  height: 140,
                                  width: double.infinity,

                                  foregroundDecoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        theme.colorScheme.surfaceContainerHigh,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          kinetic?.frostedObsidian ??
                                          Colors.black54,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // 2. Content Body
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Meta Row
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .primaryContainer
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          task.category.name.toUpperCase(),
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                              ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat(
                                              'MMM dd, yyyy',
                                            ).format(task.date),
                                            style: theme.textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Title & Checkbox Row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: theme.textTheme.displayLarge
                                              ?.copyWith(
                                                fontSize: 28,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                kinetic?.ghostBorder ??
                                                Colors.transparent,
                                          ),
                                        ),
                                        child: Icon(
                                          task.isDone
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: task.isDone
                                              ? theme.colorScheme.primary
                                              : theme
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Description & Info Grid
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "DESCRIPTION",
                                              style:
                                                  theme.textTheme.labelMedium,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              task.subtitle,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme
                                                .surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "PRIORITY",
                                                style:
                                                    theme.textTheme.labelMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.priority_high,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    task.priority == 1
                                                        ? "High"
                                                        : "Standard",
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // 3. Action Buttons
                                  Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: task.isDone
                                            ? null
                                            : () {
                                                ref
                                                    .read(
                                                      tasksProvider.notifier,
                                                    )
                                                    .toggle(task);
                                                context.pop();
                                              },
                                        style: theme.elevatedButtonTheme.style
                                            ?.copyWith(
                                              minimumSize:
                                                  WidgetStateProperty.all(
                                                    const Size(
                                                      double.infinity,
                                                      56,
                                                    ),
                                                  ),
                                            ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle_outline),
                                            SizedBox(width: 8),
                                            Text(
                                              "Complete Task",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                context.pop();
                                                showDialog(
                                                  context: context,
                                                  barrierColor: Colors.black
                                                      .withOpacity(0.85),
                                                  builder: (context) =>
                                                      EditTaskDialog(
                                                        originalTask: task,
                                                      ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              label: const Text("Edit"),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                side: BorderSide(
                                                  color:
                                                      kinetic?.ghostBorder ??
                                                      Colors.white10,
                                                ),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      tasksProvider.notifier,
                                                    )
                                                    .delete(task);
                                                context.pop();
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                              ),
                                              label: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                side: BorderSide(
                                                  color:
                                                      kinetic?.ghostBorder ??
                                                      Colors.white10,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Column(
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      task.subtitle,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(height: 20, color: Colors.white10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 10,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd').format(task.date),
                        style: theme.textTheme.labelMedium,
                      ),
                      const Spacer(),
                      Text(
                        "P${task.priority}",
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class AddTaskModal extends ConsumerStatefulWidget {
  const AddTaskModal({super.key});

  @override
  ConsumerState<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends ConsumerState<AddTaskModal> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  Category _selectedCategory = Category.work;
  int _selectedPriority = 1; // 1: Low, 2: Medium, 3: High, 4: Critical

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _submitTask() {
    if (_titleController.text.trim().isEmpty) return;

    final newTask = TaskModel(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      date: DateTime.now(),
      isDone: false,
    );

    // Call your provider
    ref.read(tasksProvider.notifier).add(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kinetic = theme.extension<KineticEffects>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Handle keyboard
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "NEW RITUAL",
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 24,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Inputs
            _buildLabel("Task Title"),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "What is the focus?"),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),

            _buildLabel("Subtitle"),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                hintText: "Add context or details...",
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 32),

            // Selection Grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Category"),
                      _buildDropdown<Category>(
                        value: _selectedCategory,
                        items: Category.values,
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Priority"),
                      _buildDropdown<int>(
                        value: _selectedPriority,
                        items: const [1, 2, 3, 4],
                        labels: const ["Low", "Medium", "High", "Critical"],
                        onChanged: (val) =>
                            setState(() => _selectedPriority = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Actions
            ElevatedButton(
              onPressed: _submitTask,
              style: theme.elevatedButtonTheme.style?.copyWith(
                minimumSize: WidgetStateProperty.all(
                  const Size(double.infinity, 64),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              child: const Text(
                "Create Task",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "DISCARD",
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    List<String>? labels,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: theme.colorScheme.surfaceContainerHigh,
          icon: const Icon(Icons.expand_more),
          items: List.generate(items.length, (index) {
            return DropdownMenuItem(
              value: items[index],
              child: Text(
                labels != null
                    ? labels[index]
                    : items[index].toString().split('.').last.toUpperCase(),
                style: const TextStyle(fontSize: 14),
              ),
            );
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
