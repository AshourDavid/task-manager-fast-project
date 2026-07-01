import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/app/theme/dark_theme.dart';
import 'package:task_manager/models/enums/category.dart';
import 'package:task_manager/models/neglect_task_model.dart';
import 'package:task_manager/providers/neglect_tasks_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _NeglectTasksPageState();
}

class _NeglectTasksPageState extends ConsumerState<AnalyticsPage> {
  // Mock data - In a real app, get this from your NeglectTasksProvider
    

  Category? _selectedFilter;

  @override
  Widget build(BuildContext context) {
      final asyncNeglect = ref.watch(neglectTasksProvider);
  late final List<NeglectTaskModel> _allTasks ;
  asyncNeglect.whenData((value) {
    _allTasks = value;
  });
    final theme = Theme.of(context);
    final kinetic = theme.extension<KineticEffects>();

    // Logic for Percentage and Filtering
    final filteredTasks = _selectedFilter == null
        ? _allTasks
        : _allTasks.where((t) => t.category == _selectedFilter).toList();

    final doneCount = _allTasks.where((t) => t.isDone).length;
    final completionPercentage = _allTasks.isEmpty 
        ? 0 
        : (doneCount / _allTasks.length * 100).toInt();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Header & Summary Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NEGLECTED", style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 4, color: theme.colorScheme.primary)),
                  Text("Rituals", style: theme.textTheme.displayLarge),
                  const SizedBox(height: 24),
                  
                  // Progress Card (Bento Style)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kinetic?.ghostBorder ?? Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Completion Rate", style: theme.textTheme.headlineMedium),
                            Text("$completionPercentage%", style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: completionPercentage / 100,
                          backgroundColor: theme.colorScheme.surfaceContainerHigh,
                          color: theme.colorScheme.primary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Filter Buttons
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _FilterChip(
                    label: "All",
                    isSelected: _selectedFilter == null,
                    onTap: () => setState(() => _selectedFilter = null),
                  ),
                  ...Category.values.map((cat) => _FilterChip(
                    label: cat.name.toUpperCase(),
                    isSelected: _selectedFilter == cat,
                    onTap: () => setState(() => _selectedFilter = cat),
                  )),
                ],
              ),
            ),
          ),

          // 3. Task List
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = filteredTasks[index];
                  return _TaskItem(task: task);
                },
                childCount: filteredTasks.length,
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

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        labelStyle: TextStyle(
          color: isSelected ? theme.colorScheme.onPrimary : Colors.white60,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        showCheckmark: false,
        
      ),
    );
  }
}

class _TaskItem extends ConsumerWidget {
  final NeglectTaskModel task;
  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context,WidgetRef ref,) {
    final theme = Theme.of(context);
    final kinetic = theme.extension<KineticEffects>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kinetic?.ghostBorder ?? Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.category.name.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.tertiaryContainer, fontSize: 8),
                ),
                const SizedBox(height: 4),
                Text(task.title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM dd').format(task.date), style: theme.textTheme.labelMedium),
                    const SizedBox(width: 12),
                    Icon(Icons.priority_high, size: 12, color: _getPriorityColor(task.priority)),
                    const SizedBox(width: 4),
                    Text("P${task.priority}", style: theme.textTheme.labelMedium),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              
                showDialog(  context: context,
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
                                                      neglectTasksProvider.notifier,
                                                    )
                                                    .delete(task);
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
                                                      neglectTasksProvider.notifier,
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
            }, // Detail view action
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 3) return Colors.redAccent;
    if (priority == 2) return Colors.orangeAccent;
    return Colors.greenAccent;
  }
}




class EditTaskDialog extends ConsumerStatefulWidget {
  final NeglectTaskModel originalTask;

  const EditTaskDialog({super.key, required this.originalTask});

  @override
  ConsumerState<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late Category _selectedCategory;
  late int _selectedPriority;
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.originalTask.title);
    _subtitleController = TextEditingController(text: widget.originalTask.subtitle);
    _selectedCategory = widget.originalTask.category;
    _selectedPriority = widget.originalTask.priority;
    _isDone = widget.originalTask.isDone;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final updatedTask = widget.originalTask.copyWith(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      isDone: _isDone,
    );

    ref.read(neglectTasksProvider.notifier).modify(widget.originalTask, updatedTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kinetic = theme.extension<KineticEffects>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kinetic?.ghostBorder ?? Colors.white10),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Banner (Matches Details Dialog)
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://picsum.photos/seed/edit/600/200'),
                        fit: BoxFit.cover,
                        opacity: 0.6,
                      ),
                    ),
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
                        backgroundColor: kinetic?.frostedObsidian ?? Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 24,
                    child: Text(
                      "EDIT RITUAL",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Dialog Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
                      decoration: const InputDecoration(
                        hintText: "Ritual Title",
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Subtitle/Description Input
                    _buildLabel(theme, "Description"),
                    TextField(
                      controller: _subtitleController,
                      maxLines: 2,
                      style: theme.textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: "Refine the details...",
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(theme, "Category"),
                              _buildDropdown<Category>(
                                theme: theme,
                                value: _selectedCategory,
                                items: Category.values,
                                onChanged: (val) => setState(() => _selectedCategory = val!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(theme, "Priority"),
                              _buildDropdown<int>(
                                theme: theme,
                                value: _selectedPriority,
                                items: const [1, 2, 3, 4],
                                labels: const ["Low", "Med", "High", "Crit"],
                                onChanged: (val) => setState(() => _selectedPriority = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Done Toggle (Kinetic Style)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kinetic?.ghostBorder ?? Colors.white10),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("COMPLETED", style: theme.textTheme.labelMedium),
                        activeColor: theme.colorScheme.primary,
                        value: _isDone,
                        onChanged: (val) => setState(() => _isDone = val),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. Action Buttons (Matches Details Dialog)
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_as_outlined),
                          SizedBox(width: 8),
                          Text("Save Changes", style: TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "CANCEL",
                          style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required ThemeData theme,
    required T value,
    required List<T> items,
    List<String>? labels,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: theme.colorScheme.surfaceContainerHigh,
          icon: const Icon(Icons.arrow_drop_down),
          items: List.generate(items.length, (i) {
            return DropdownMenuItem(
              value: items[i],
              child: Text(
                labels != null ? labels[i] : items[i].toString().split('.').last.toUpperCase(),
                style: const TextStyle(fontSize: 13),
              ),
            );
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }
}