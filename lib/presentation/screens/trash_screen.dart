import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/task_repository.dart';

class TrashScreen extends StatelessWidget {
  final TaskRepository taskRepository;

  const TrashScreen({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина (Soft Delete)')),
      body: StreamBuilder<List<TaskEntity>>(
        stream: taskRepository.watchDeletedTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Корзина пуста'));
          }

          final deletedTasks = snapshot.data!;
          return ListView.builder(
            itemCount: deletedTasks.length,
            itemBuilder: (context, index) {
              final task = deletedTasks[index];
              return ListTile(
                title: Text(task.title, style: const TextStyle(decoration: TextDecoration.lineThrough)),
                subtitle: Text('Удалено: ${task.deletedAt}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore, color: Colors.green),
                      onPressed: () => taskRepository.restoreTask(task.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () => taskRepository.permanentlyDeleteTask(task.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}