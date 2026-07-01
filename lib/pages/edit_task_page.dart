import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/app/theme/dark_theme.dart';
import 'package:task_manager/models/enums/category.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/tasks_provider.dart';
class EditTaskDialog extends ConsumerStatefulWidget {
  final TaskModel originalTask;

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

    ref.read(tasksProvider.notifier).modify(widget.originalTask, updatedTask);
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