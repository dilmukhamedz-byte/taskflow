import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/task_repository.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskEntity task;
  final TaskRepository taskRepository;
  final UserEntity? currentUser;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.taskRepository,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(task.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Text('Статус: ${task.status.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Приоритет: ${task.priority.name}'),
          Text('Дедлайн: ${task.deadline.toLocal()}'.split('.')[0]),
          const Divider(height: 32),
          
          // История изменений
          const Text('История изменений статуса', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          StreamBuilder<List<TaskHistoryEntity>>(
            stream: taskRepository.watchTaskHistory(task.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('История пуста'),
                );
              }
              return Column(
                children: snapshot.data!.map((history) => ListTile(
                  dense: true,
                  title: Text('${history.previousStatus?.name ?? "start"} ➔ ${history.newStatus.name}'),
                  subtitle: Text('${history.timestamp}'),
                )).toList(),
              );
            },
          ),
          
          const Divider(height: 32),

          // Комментарии
          const Text('Комментарии', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          StreamBuilder<List<CommentEntity>>(
            stream: taskRepository.watchTaskComments(task.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Пока нет комментариев'),
                );
              }
              return Column(
                children: snapshot.data!.map((comment) => ListTile(
                  title: Text(comment.content),
                  subtitle: Text('${comment.creationDate}'),
                )).toList(),
              );
            },
          ),
          
          const SizedBox(height: 10),
          TextField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: 'Добавить комментарий',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  if (commentController.text.isNotEmpty && currentUser != null) {
                    await taskRepository.addComment(
                      taskId: task.id,
                      authorId: currentUser!.id,
                      content: commentController.text,
                    );
                    commentController.clear();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}