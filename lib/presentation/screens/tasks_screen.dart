import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/task_repository.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
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
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Задачи проекта')),
      body: StreamBuilder<List<TaskEntity>>(
        stream: widget.taskRepository.watchProjectTasks(widget.projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет активных задач'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(
                        task: task,
                        taskRepository: widget.taskRepository,
                        currentUser: widget.currentUser,
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => widget.taskRepository.softDeleteTask(task.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}