// lib/dashboard/dashboard_screen.dart
import 'package:assg/auth/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../user_provider.dart';
import 'task_provider.dart';
import 'task_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Task',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final taskText = _taskController.text.trim();
                if (taskText.isNotEmpty) {
                  try {
                    await Provider.of<TaskProvider>(context, listen: false)
                        .addTask(taskText);
                    _taskController.clear();

                    // Refresh to ensure UI updates
                    await Provider.of<TaskProvider>(context, listen: false)
                        .fetchTasks();

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add task: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4C542),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add Task',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DayTask'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, ${userProvider.userName.isNotEmpty ? userProvider.userName : 'User'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => taskProvider.fetchTasks(),
              child: taskProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : taskProvider.tasks.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Text(
                                'No tasks yet. Add some!',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: taskProvider.tasks.length,
                          itemBuilder: (context, index) {
                            return TaskTile(task: taskProvider.tasks[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskBottomSheet,
        backgroundColor: const Color(0xFFF4C542),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
