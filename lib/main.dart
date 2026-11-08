import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'data/database/app_database.dart';
import 'data/repositories/task_repository.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/tasks_screen.dart';
import 'presentation/screens/trash_screen.dart';
import 'presentation/screens/profile_screen.dart';

late AppDatabase db;
late TaskRepository taskRepository;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  db = AppDatabase(NativeDatabase.memory(
    setup: (database) {
      database.execute('PRAGMA foreign_keys = ON;');
    },
  ));
  taskRepository = TaskRepository(db);

  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  UserEntity? currentUser;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _updateScreens();
  }

  void _updateScreens() {
    _screens = [
      DashboardScreen(taskRepository: taskRepository),
      TasksScreen(
        taskRepository: taskRepository,
        projectId: 1,
        currentUser: currentUser,
      ),
      TrashScreen(taskRepository: taskRepository),
      ProfileScreen(
        taskRepository: taskRepository,
        currentUser: currentUser,
        onUserSelected: (user) {
          setState(() {
            currentUser = user;
            _updateScreens();
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Статистика'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Задачи'),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Корзина'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}