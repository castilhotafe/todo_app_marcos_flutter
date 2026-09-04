import 'package:flutter/material.dart';
import 'package:todo_app_marcos/models/todo.dart';

class TodoWidget extends StatefulWidget {
  const TodoWidget({required this.todo, super.key});
  final Todo todo;

  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: NetworkImage(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROzcg6lJRaznvAJzAq2Z6F9x_u6eLaid0WjPPqRGNSndCTP4uScTUlu0PL&s=10',
          ),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: Color.fromARGB(255, 225, 225, 225), width: 8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 95, 94, 115),
            offset: Offset(5, 5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.todo.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.todo.description,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
