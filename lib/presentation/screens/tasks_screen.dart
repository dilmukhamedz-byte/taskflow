import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/injection_container.dart';
import 'package:taskflow/data/database/app_database.dart';
import 'package:taskflow/data/repositories/task_repository.dart';
import 'package:taskflow/presentation/bloc/task_bloc.dart';
import 'package:taskflow/presentation/bloc/task_event.dart';
import 'package:taskflow/presentation/bloc/task_state.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatelessWidget {
  final TaskRepository taskRepository;
  final int projectId;
  final UserEntity? currentUser;

  const TasksScreen({
    super.key,
    required this.taskRepository,
    required this.projectId,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>()..add(LoadTasksEvent(projectId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Задачи проекта')),
        body: Column(
          children: [
            // Строка поиска (новая функция по заданию)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  return TextField(
                    decoration: const InputDecoration(
                      labelText: 'Поиск задач...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) {
                      context.read<TaskBloc>().add(SearchTasksEvent(query));
                    },
                  );
                },
              ),
            ),
            // Список задач
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is TaskLoaded) {
                    final tasks = state.tasks;
                    if (tasks.isEmpty) {
                      return const Center(child: Text('Задачи не найдены'));
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          title: Text(task.title),
                          subtitle: Text(task.description.toString()),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(
                                  task: task as dynamic,
                                  taskRepository: taskRepository,
                                  currentUser: currentUser,
                                ),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              final navigatorContext = context;
                              taskRepository.softDeleteTask(task.id).then((_) {
                                if (!navigatorContext.mounted) return;
                                navigatorContext.read<TaskBloc>().add(LoadTasksEvent(projectId));
                              });
                            },
                          ),
                        );
                      },
                    );
                  }

                  if (state is TaskEmpty) {
                    return const Center(child: Text('Список задач пуст'));
                  }

                  if (state is TaskError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}