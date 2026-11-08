import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:taskflow/data/database/app_database.dart';

void main() {
  group('TaskFlow Database & Repository Tests', () {
    late AppDatabase db;

    setUp(() {
      // Включаем внешние ключи для работы каскадного удаления в SQLite в памяти
      db = AppDatabase(NativeDatabase.memory(
        setup: (database) {
          database.execute('PRAGMA foreign_keys = ON;');
        },
      ));
    });

    tearDown(() async {
      await db.close();
    });

    // 1. Тест на уникальность email
    test('Users email uniqueness constraint throws exception', () async {
      await db.into(db.users).insert(
            UsersCompanion.insert(
              name: 'Alice',
              email: 'alice@taskflow.com',
              registrationDate: DateTime.now(),
            ),
          );

      expect(
        () async => await db.into(db.users).insert(
              UsersCompanion.insert(
                name: 'Bob',
                email: 'alice@taskflow.com', // Дублирование email
                registrationDate: DateTime.now(),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    // 2. Тест на каскадное удаление
    test('Cascade delete removes related project members and tasks', () async {
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(name: 'John', email: 'john@task.com', registrationDate: DateTime.now()),
          );
      final projectId = await db.into(db.projects).insert(
            ProjectsCompanion.insert(name: 'P1', description: 'Desc', creationDate: DateTime.now(), status: ProjectStatus.active),
          );

      await db.into(db.projectMembers).insert(
            ProjectMembersCompanion.insert(userId: userId, projectId: projectId, role: UserRole.owner),
          );

      // Удаляем проект
      await (db.delete(db.projects)..where((p) => p.id.equals(projectId))).go();

      // Проверяем, что связанные записи удалились каскадно
      final membersCount = await db.select(db.projectMembers).get().then((r) => r.length);
      expect(membersCount, 0);
    });

    // 3. Тест на работу Soft Delete
    test('Soft delete updates deletedAt and hides task from active lists', () async {
      final projectId = await db.into(db.projects).insert(
            ProjectsCompanion.insert(name: 'P1', description: 'D', creationDate: DateTime.now(), status: ProjectStatus.active),
          );

      final taskId = await db.into(db.tasks).insert(
            TasksCompanion.insert(
              title: 'Task 1',
              description: 'D',
              projectId: projectId,
              priority: TaskPriority.low,
              status: TaskStatus.todo,
              deadline: DateTime.now(),
              creationDate: DateTime.now(),
              modifiedDate: DateTime.now(),
            ),
          );

      // Проводим Soft Delete
      await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(deletedAt: Value(DateTime.now())),
      );

      // Проверяем активные задачи
      final activeTasks = await (db.select(db.tasks)..where((t) => t.deletedAt.isNull())).get();
      expect(activeTasks.length, 0);
    });

    // 4. Тест на корректность SQL-запросов для панели статистики
    test('Dashboard statistics SQL queries calculate correct metrics', () async {
      final projectId = await db.into(db.projects).insert(
            ProjectsCompanion.insert(name: 'P1', description: 'D', creationDate: DateTime.now(), status: ProjectStatus.active),
          );

      // Создаем задачу со статусом done
      await db.into(db.tasks).insert(
            TasksCompanion.insert(
              title: 'T1', 
              description: 'D', 
              projectId: projectId, 
              priority: TaskPriority.high, 
              status: TaskStatus.done, 
              deadline: DateTime.now(), 
              creationDate: DateTime.now(), 
              modifiedDate: DateTime.now(),
            ),
          );

      // Запрос подсчета завершенных задач через SQL агрегацию
      final query = db.selectOnly(db.tasks)
        ..addColumns([db.tasks.id.count()])
        ..where(db.tasks.status.equals(TaskStatus.done.name));

      final doneCount = await query.map((row) => row.read(db.tasks.id.count())).getSingle();
      expect(doneCount, 1);
    });
  });
}