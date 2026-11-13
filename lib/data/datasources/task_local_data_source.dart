import 'package:drift/drift.dart';
// Импортируем чистую сущность Domain и даем ей префикс или используем точечный импорт
import '../../domain/entities/task_entity.dart' as domain;
import '../database/app_database.dart';

abstract class TaskLocalDataSource {
  Future<List<domain.TaskEntity>> getProjectTasks(int projectId);
  Future<void> softDeleteTask(int taskId);
  Future<void> restoreTask(int taskId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final AppDatabase db;

  TaskLocalDataSourceImpl(this.db);

  @override
  Future<List<domain.TaskEntity>> getProjectTasks(int projectId) async {
    final results = await (db.select(db.tasks)
          ..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull()))
        .get();

    // Маппинг из базы данных (Drift) в чистую сущность Domain
    return results.map((t) => domain.TaskEntity(
          id: t.id,
          title: t.title,
          description: t.description,
          projectId: t.projectId,
          status: t.status.name,
          priority: t.priority.name,
          deadline: t.deadline,
          deletedAt: t.deletedAt,
        )).toList();
  }

  @override
  Future<void> softDeleteTask(int taskId) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  @override
  Future<void> restoreTask(int taskId) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
      const TasksCompanion(deletedAt: Value(null)),
    );
  }
}