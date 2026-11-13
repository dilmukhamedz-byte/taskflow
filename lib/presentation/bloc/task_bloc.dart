import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/domain/entities/task_entity.dart';
import 'package:taskflow/usecases/get_tasks_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  
  // Сохраняем все загруженные задачи для локальной фильтрации
  List<TaskEntity> _allTasks = [];

  TaskBloc({required this.getTasksUseCase}) : super(TaskInitial()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TaskLoading());

      final result = await getTasksUseCase(event.projectId);

      result.fold(
        (failure) => emit(TaskError('Не удалось загрузить задачи')),
        (tasks) {
          _allTasks = tasks;
          if (_allTasks.isEmpty) {
            emit(TaskEmpty());
          } else {
            emit(TaskLoaded(_allTasks));
          }
        },
      );
    });

    on<SearchTasksEvent>((event, emit) {
      if (_allTasks.isEmpty) return;

      final query = event.query.toLowerCase();
      if (query.isEmpty) {
        emit(TaskLoaded(_allTasks));
        return;
      }

      final filtered = _allTasks.where((task) {
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch = task.description.toLowerCase().contains(query);
        return titleMatch || descMatch;
      }).toList();

      if (filtered.isEmpty) {
        emit(TaskEmpty());
      } else {
        emit(TaskLoaded(filtered));
      }
    });
  }
}