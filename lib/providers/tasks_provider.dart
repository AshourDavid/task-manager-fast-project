import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/models/enums/category.dart';
import '../models/task_model.dart';

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(
  () => TasksNotifier(),
);

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() async {
    state = AsyncLoading();
    return [TaskModel(
    title: 'Kinetic Noir UI Refinement',
    subtitle: 'Finalize the frosted glass effects and ghost borders for the task cards.',
    priority: 1,
    date: DateTime.now().add(const Duration(hours: 2)),
    category: Category.work,
  ),
  TaskModel(
    title: 'Chopin Nocturne Practice',
    subtitle: 'Focus on the left-hand rubato sections in Op. 9 No. 2.',
    priority: 2,
    date: DateTime.now().add(const Duration(days: 1)),
    category: Category.fun,
  ),
  TaskModel(
    title: 'Supabase Integration',
    subtitle: 'Set up Row Level Security (RLS) policies for the Tones Studio database.',
    priority: 1,
    date: DateTime.now().subtract(const Duration(hours: 5)),
    category: Category.work,
    isDone: true,
  ),
  TaskModel(
    title: 'Bicycle Maintenance',
    subtitle: 'Clean the drivetrain and check tire pressure for the weekend trail ride.',
    priority: 3,
    date: DateTime.now().add(const Duration(days: 2)),
    category: Category.other,
  ),
  TaskModel(
    title: 'Advanced AI Research',
    subtitle: 'Review documentation for Transformer architectures and attention mechanisms.',
    priority: 2,
    date: DateTime.now().add(const Duration(hours: 8)),
    category: Category.study,
  ),
  TaskModel(
    title: 'Nature Photography Walk',
    subtitle: 'Explore the local park during golden hour for high-contrast lighting shots.',
    priority: 3,
    date: DateTime.now().add(const Duration(days: 3)),
    category: Category.fun,
  ),];
  }

  Future<void> add(TaskModel task) async {
    state = AsyncValue.data([...state.value ?? [], task]);
  }

  Future<void> delete(TaskModel task) async {
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((t) => t != task).toList());
  }

  Future<void> modify(TaskModel oldTask, TaskModel newTask) async {
    final current = state.value ?? [];
   final index = current.indexOf(oldTask);

    final updated = current.where((t) => t != oldTask).toList()..insert(index,newTask);
    state = AsyncValue.data(updated);
  }

  Future<void> toggle(TaskModel task) async {
    
    final current = state.value ?? [];
    final updated = current
        .map((t) => t == task ? t.copyWith(isDone: !t.isDone) : t)
        .toList();
    state = AsyncValue.data(updated);
  }


  Future<void> getAllTasks( )async{
    state = AsyncLoading();

    state = AsyncValue.data([]);
  }
}
