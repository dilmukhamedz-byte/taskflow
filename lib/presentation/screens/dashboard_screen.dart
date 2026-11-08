import 'package:flutter/material.dart';
import '../../data/repositories/task_repository.dart';

class DashboardScreen extends StatelessWidget {
  final TaskRepository taskRepository;

  const DashboardScreen({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Панель статистики (Dashboard)')),
      body: FutureBuilder(
        future: Future.wait([
          taskRepository.getTotalProjectsCount(),
          taskRepository.getTotalTasksCount(),
          taskRepository.getCompletedTasksCount(),
          taskRepository.getUncompletedTasksCount(),
          taskRepository.getOverdueTasksCount(),
        ]),
        builder: (context, AsyncSnapshot<List<int>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final counts = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatCard(title: 'Всего проектов', count: counts[0], color: Colors.blue),
              _StatCard(title: 'Всего задач', count: counts[1], color: Colors.indigo),
              _StatCard(title: 'Завершенные задачи', count: counts[2], color: Colors.green),
              _StatCard(title: 'Незавершенные задачи', count: counts[3], color: Colors.orange),
              _StatCard(title: 'Просроченные задачи', count: counts[4], color: Colors.red),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _StatCard({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}