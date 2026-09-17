import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';
import 'package:todo_app_marcos/services/sqlite_data_source.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/models/todo_list.dart';
import 'package:todo_app_marcos/views/todo_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<IDataSource>(() => SQLiteDataSource.createAsync());
  final model = TodoList();
  await model.refresh();
  runApp(
    ChangeNotifierProvider(create: (context) => model, child: const TodoApp()),
  );
}

// App principal.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Todo List', home: TodoHomePage());
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void _openAddTodo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final todo = Todo(
                    name: nameController.text,
                    description: descriptionController.text,
                  );

                  await Provider.of<TodoList>(context, listen: false).add(todo);

                  nameController.clear();
                  descriptionController.clear();

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          Consumer<TodoList>(
            builder: (context, model, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Center(
                  child: Text(
                    '${model.todos.where((todo) => !todo.complete).length} to do',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TodoList>(
        builder: (context, model, child) {
          return RefreshIndicator(
            onRefresh: model.refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: model.todoCount,
              itemBuilder: (context, index) {
                return TodoWidget(todo: model.todos[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTodo,
        tooltip: 'Add Todo',
        child: const FaIcon(FontAwesomeIcons.brazilianRealSign),
      ),
    );
  }
}
