import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/task_repository.dart';

class ProfileScreen extends StatelessWidget {
  final TaskRepository taskRepository;
  final Function(UserEntity) onUserSelected;
  final UserEntity? currentUser;

  const ProfileScreen({
    super.key,
    required this.taskRepository,
    required this.onUserSelected,
    required this.currentUser,
  });

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый пользователь'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Имя'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                await taskRepository.db.into(taskRepository.db.users).insert(
                      UsersCompanion.insert(
                        name: nameController.text,
                        email: emailController.text,
                        registrationDate: DateTime.now(),
                      ),
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль / Выбор пользователя'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Добавить пользователя',
            onPressed: () => _showAddUserDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<UserEntity>>(
        stream: taskRepository.db.select(taskRepository.db.users).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (currentUser != null)
                Card(
                  color: Colors.blue.shade50,
                  child: ListTile(
                    title: Text('Текущий пользователь: ${currentUser!.name}'),
                    subtitle: Text(currentUser!.email),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Доступные пользователи:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Добавить'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (users.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Список пуст. Создайте первого пользователя.')),
                ),
              ...users.map((user) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: ElevatedButton(
                      onPressed: () => onUserSelected(user),
                      child: const Text('Выбрать'),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}