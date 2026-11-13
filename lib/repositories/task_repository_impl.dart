import 'package:dartz/dartz.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/domain/entities/task_entity.dart';
import 'package:taskflow/repositories/task_repository.dart'; // <--- Исправленный путь
import 'package:taskflow/data/datasources/task_local_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<TaskEntity>>> getProjectTasks(int projectId) async {
    try {
      final tasks = await localDataSource.getProjectTasks(projectId);
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createTask(TaskEntity task, int userId) async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> softDeleteTask(int taskId) async {
    try {
      await localDataSource.softDeleteTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> restoreTask(int taskId) async {
    try {
      await localDataSource.restoreTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}