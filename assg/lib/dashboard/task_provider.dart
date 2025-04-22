import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'task_model.dart';

class TaskProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _tasks = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _tasks = (response as List).map((task) => Task.fromJson(task)).toList();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('tasks')
          .insert({
            'title': title,
            'is_completed': false,
            'user_id': userId,
          })
          .select()
          .single(); // get full task record including id

      final newTask = Task.fromJson(response);
      _tasks.insert(0, newTask); // insert at the top
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      final newStatus = !task.isCompleted;

      await _supabase
          .from('tasks')
          .update({'is_completed': newStatus}).eq('id', task.id);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(isCompleted: newStatus);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task status: $e');
    }
  }

  // Optional alias for compatibility
  Future<void> toggleTaskStatus(Task task) async {
    return toggleTaskCompletion(task);
  }
}
