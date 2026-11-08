import 'package:drift/drift.dart';
import '../database/app_database.dart';

class TaskRepository {
  final AppDatabase db;

  TaskRepository(this.db);

  // Транзакция: создание задачи и первой записи в истории[cite: 5]
  Future<void> createTaskWithHistory({
    required TasksCompanion taskCompanion,
    required int userId,
  }) async {
    await db.transaction(() async {
      final taskId = await db.into(db.tasks).insert(taskCompanion);

      await db.into(db.taskHistory).insert(
            TaskHistoryCompanion.insert(
              taskId: taskId,
              previousStatus: const Value.absent(),
              newStatus: TaskStatus.todo,
              changedById: userId,
              timestamp: DateTime.now(),
            ),
          );
    });
  }

  // Задание повышенной сложности №3: Ограничение (не более 3 незавершенных задач на ту же дату)
  Future<bool> canAssignTask(int userId, DateTime deadline) async {
    final query = db.select(db.tasks)
      ..where((t) =>
          t.assigneeId.equals(userId) &
          t.deadline.equals(deadline) &
          t.status.isNotIn([TaskStatus.done.name, TaskStatus.cancelled.name]) &
          t.deletedAt.isNull());

    final count = await query.get().then((rows) => rows.length);
    return count < 3;
  }

  // Задание повышенной сложности №1: Soft Delete
  Future<void> softDeleteTask(int taskId) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  // Реактивный поток данных[cite: 5]
  Stream<List<TaskEntity>> watchProjectTasks(int projectId) {
    return (db.select(db.tasks)
          ..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull()))
        .watch();
  }

  // ==========================================
  // МЕТОДЫ ДЛЯ РАБОТЫ С КОРЗИНОЙ (Soft Delete / Trash)
  // ==========================================

  // Получение потока удаленных задач
  Stream<List<TaskEntity>> watchDeletedTasks() {
    return (db.select(db.tasks)
          ..where((t) => t.deletedAt.isNotNull()))
        .watch();
  }

  // Восстановление задачи из корзины
  Future<void> restoreTask(int taskId) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
      const TasksCompanion(deletedAt: Value(null)),
    );
  }

  // Полное удаление задачи из базы данных
  Future<void> permanentlyDeleteTask(int taskId) async {
    await (db.delete(db.tasks)..where((t) => t.id.equals(taskId))).go();
  }

  // ==========================================
  // МЕТОДЫ ДЛЯ КОММЕНТАРИЕВ И ИСТОРИИ
  // ==========================================

  // Добавление комментария к задаче
  Future<void> addComment({
    required int taskId,
    required int authorId,
    required String content,
  }) async {
    await db.into(db.comments).insert(
          CommentsCompanion.insert(
            content: content,
            authorId: authorId,
            taskId: taskId,
            creationDate: DateTime.now(),
          ),
        );
  }

  // Получение потока комментариев для задачи
  Stream<List<CommentEntity>> watchTaskComments(int taskId) {
    return (db.select(db.comments)
          ..where((c) => c.taskId.equals(taskId)))
        .watch();
  }

  // Получение истории изменения статусов задачи
  Stream<List<TaskHistoryEntity>> watchTaskHistory(int taskId) {
    return (db.select(db.taskHistory)
          ..where((h) => h.taskId.equals(taskId)))
        .watch();
  }

  // ==========================================
  // МЕТОДЫ ПАНЕЛИ СТАТИСТИКИ (Dashboard)[cite: 4]
  // Рассчитываются напрямую через SQL-запросы к SQLite
  // ==========================================

  // 1. Общее количество завершенных задач
  Future<int> getCompletedTasksCount() async {
    final query = db.selectOnly(db.tasks)
      ..addColumns([db.tasks.id.count()])
      ..where(db.tasks.status.equals(TaskStatus.done.name) & db.tasks.deletedAt.isNull());
    return await query.map((row) => row.read(db.tasks.id.count())).getSingle() ?? 0;
  }

  // 2. Общее количество незавершенных задач
  Future<int> getUncompletedTasksCount() async {
    final query = db.selectOnly(db.tasks)
      ..addColumns([db.tasks.id.count()])
      ..where(db.tasks.status.isNotIn([TaskStatus.done.name, TaskStatus.cancelled.name]) & db.tasks.deletedAt.isNull());
    return await query.map((row) => row.read(db.tasks.id.count())).getSingle() ?? 0;
  }

  // 3. Общее количество просроченных задач
  Future<int> getOverdueTasksCount() async {
    final now = DateTime.now();
    final query = db.selectOnly(db.tasks)
      ..addColumns([db.tasks.id.count()])
      ..where(
        db.tasks.deadline.isSmallerThanValue(now) &
        db.tasks.status.isNotIn([TaskStatus.done.name, TaskStatus.cancelled.name]) &
        db.tasks.deletedAt.isNull(),
      );
    return await query.map((row) => row.read(db.tasks.id.count())).getSingle() ?? 0;
  }

  // 4. Общее количество проектов
  Future<int> getTotalProjectsCount() async {
    final query = db.selectOnly(db.projects)..addColumns([db.projects.id.count()]);
    return await query.map((row) => row.read(db.projects.id.count())).getSingle() ?? 0;
  }

  // 5. Общее количество задач
  Future<int> getTotalTasksCount() async {
    final query = db.selectOnly(db.tasks)
      ..addColumns([db.tasks.id.count()])
      ..where(db.tasks.deletedAt.isNull());
    return await query.map((row) => row.read(db.tasks.id.count())).getSingle() ?? 0;
  }
}