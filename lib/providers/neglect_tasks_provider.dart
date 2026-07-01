import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/models/enums/category.dart';
import '../../models/neglect_task_model.dart';

final neglectTasksProvider =
    AsyncNotifierProvider<NeglectTasksNotifier, List<NeglectTaskModel>>(
      () => NeglectTasksNotifier(),
    );

class NeglectTasksNotifier extends AsyncNotifier<List<NeglectTaskModel>> {
  @override
  Future<List<NeglectTaskModel>> build() async {
    state = AsyncLoading();
    return [
      NeglectTaskModel(
        title: 'Kinetic Noir UI Refinement',
        subtitle:
            'Finalize the frosted glass effects and ghost borders for the task cards.',
        priority: 1,
        date: DateTime.now().add(const Duration(hours: 2)),
        category: Category.work,
      ),
      NeglectTaskModel(
        title: 'Chopin Nocturne Practice',
        subtitle: 'Focus on the left-hand rubato sections in Op. 9 No. 2.',
        priority: 2,
        date: DateTime.now().add(const Duration(days: 1)),
        category: Category.fun,
      ),
      NeglectTaskModel(
        title: 'Supabase Integration',
        subtitle:
            'Set up Row Level Security (RLS) policies for the Tones Studio database.',
        priority: 1,
        date: DateTime.now().subtract(const Duration(hours: 5)),
        category: Category.work,
        isDone: true,
      ),
      NeglectTaskModel(
        title: 'Bicycle Maintenance',
        subtitle:
            'Clean the drivetrain and check tire pressure for the weekend trail ride.',
        priority: 3,
        date: DateTime.now().add(const Duration(days: 2)),
        category: Category.other,
      ),
      NeglectTaskModel(
        title: 'Advanced AI Research',
        subtitle:
            'Review documentation for Transformer architectures and attention mechanisms.',
        priority: 2,
        date: DateTime.now().add(const Duration(hours: 8)),
        category: Category.study,
      ),
      NeglectTaskModel(
        title: 'Nature Photography Walk',
        subtitle:
            'Explore the local park during golden hour for high-contrast lighting shots.',
        priority: 3,
        date: DateTime.now().add(const Duration(days: 3)),
        category: Category.fun,
      ),
    ];
  }

  Future<void> modify(
    NeglectTaskModel oldTask,
    NeglectTaskModel newTask,
  ) async {
    final current = state.value ?? [];
    final index = current.indexOf(oldTask);

    final updated = current.where((t) => t != oldTask).toList()
      ..insert(index, newTask);
    state = AsyncValue.data(updated);
  }

  Future<void> delete(NeglectTaskModel task) async {
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((t) => t != task).toList());
  }

  Future<void> getAllTasks() async {
    state = AsyncLoading();

    state = AsyncValue.data([]);
  }

  Future<void> toggle(NeglectTaskModel task) async {
    final current = state.value ?? [];
    final updated = current
        .map((t) => t == task ? t.copyWith(isDone: !t.isDone) : t)
        .toList();
    state = AsyncValue.data(updated);
  }
}
