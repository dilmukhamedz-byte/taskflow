import 'package:dartz/dartz.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/usecases/usecase.dart';
import 'package:taskflow/domain/entities/task_entity.dart';
import 'package:taskflow/repositories/task_repository.dart'; // <--- Исправленный путь

class GetTasksUseCase implements UseCase<List<TaskEntity>, int> {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(int projectId) async {
    return await repository.getProjectTasks(projectId);
  }
}