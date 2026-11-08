import 'package:drift/drift.dart';

part 'app_database.g.dart';

// Энамы для статусов, приоритетов и ролей
enum UserRole { owner, admin, member }
enum TaskStatus { todo, inProgress, done, cancelled }
enum TaskPriority { low, medium, high, critical }
enum ProjectStatus { active, completed, archived }

@DataClassName('UserEntity')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  DateTimeColumn get registrationDate => dateTime()();
}

@DataClassName('ProjectEntity')
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get completionDate => dateTime().nullable()();
  TextColumn get status => textEnum<ProjectStatus>()();
}

@DataClassName('ProjectMemberEntity')
class ProjectMembers extends Table {
  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get projectId => integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => textEnum<UserRole>()();

  @override
  Set<Column> get primaryKey => {userId, projectId};
}

@DataClassName('TaskEntity')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get projectId => integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  IntColumn get assigneeId => integer().nullable().references(Users, #id, onDelete: KeyAction.setNull)();
  TextColumn get priority => textEnum<TaskPriority>()();
  TextColumn get status => textEnum<TaskStatus>()();
  DateTimeColumn get deadline => dateTime()();
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get modifiedDate => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('CommentEntity')
class Comments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  IntColumn get authorId => integer().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get taskId => integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get creationDate => dateTime()();
}

@DataClassName('AttachmentEntity')
class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  IntColumn get taskId => integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get addedDate => dateTime()();
}

@DataClassName('TaskHistoryEntity')
class TaskHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get previousStatus => textEnum<TaskStatus>().nullable()();
  TextColumn get newStatus => textEnum<TaskStatus>()();
  IntColumn get changedById => integer().references(Users, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get timestamp => dateTime()();
}

@DriftDatabase(tables: [
  Users,
  Projects,
  ProjectMembers,
  Tasks,
  Comments,
  Attachments,
  TaskHistory,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1) {
            await m.addColumn(tasks, tasks.priority);
            await customStatement(
              "UPDATE tasks SET priority = 'medium' WHERE priority IS NULL",
            );
          }
        },
      );
}