// lib/dashboard/task_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_model.dart';
import 'task_provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      },
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: const Color(0xFFF4C542),
          onChanged: (_) {
            Provider.of<TaskProvider>(context, listen: false)
                .toggleTaskCompletion(task);
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            Provider.of<TaskProvider>(context, listen: false)
                .deleteTask(task.id);
          },
        ),
      ),
    );
  }
}
