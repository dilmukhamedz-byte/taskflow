import 'package:taskflow/domain/entities/task_entity.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  TaskLoaded(this.tasks);
}

class TaskEmpty extends TaskState {}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}