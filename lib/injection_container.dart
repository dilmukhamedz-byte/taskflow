import 'package:get_it/get_it.dart';
import 'package:drift/native.dart';
import 'data/database/app_database.dart';
import 'data/datasources/task_local_data_source.dart';
import 'repositories/task_repository_impl.dart';
import 'repositories/task_repository.dart';
import 'usecases/get_tasks_usecase.dart';
import 'presentation/bloc/task_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // База данных Drift
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase(NativeDatabase.memory(
    setup: (database) {
      database.execute('PRAGMA foreign_keys = ON;');
    },
  )));

  // Data Sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerFactory(
    () => GetTasksUseCase(sl()),
  );

  // Presentation / Bloc
  sl.registerFactory(
    () => TaskBloc(getTasksUseCase: sl()),
  );
}