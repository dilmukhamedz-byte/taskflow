import 'package:dartz/dartz.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getProjectTasks(int projectId);
  Future<Either<Failure, void>> createTask(TaskEntity task, int userId);
  Future<Either<Failure, void>> softDeleteTask(int taskId);
  Future<Either<Failure, void>> restoreTask(int taskId);
}