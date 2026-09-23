import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/models/todo_list.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';

import 'support/mock_data_source.dart';

void main() {
  late TodoList model;

  setUp(() {
    Get.put<IDataSource>(MockDataSource());
    model = TodoList();
  });

  tearDown(() {
    model.dispose();
    Get.reset();
  });

  test('Completing a Todo keeps the item and marks it complete', () async {
    await model.add(Todo(name: 'Read', description: 'Read the lesson'));
    final saved = model.todos.single;
    expect(saved.complete, isFalse);

    await model.updateTodo(
      Todo(
        id: saved.id,
        name: saved.name,
        description: saved.description,
        complete: true,
      ),
    );

    expect(model.todoCount, 1);
    final completed = model.todos.single;
    expect(completed.id, saved.id);
    expect(completed.name, saved.name);
    expect(completed.description, saved.description);
    expect(completed.complete, isTrue);
  });

  test('Removing one Todo keeps the other Todo', () async {
    await model.add(Todo(name: 'Read', description: 'Read the lesson'));
    await model.add(Todo(name: 'Practise', description: 'Do the exercise'));
    final removed = model.todos.first;
    final remaining = model.todos.last;
    expect(model.todoCount, 2);

    await model.remove(removed);

    expect(model.todoCount, 1);
    expect(model.todos.any((todo) => todo.id == removed.id), isFalse);
    expect(model.todos.single.id, remaining.id);
    expect(model.todos.single.name, remaining.name);
    expect(model.todos.single.description, remaining.description);
  });

  test('Removing all Todos leaves an empty list', () async {
    await model.add(Todo(name: 'Read', description: 'Read the lesson'));
    await model.add(Todo(name: 'Practise', description: 'Do the exercise'));
    expect(model.todoCount, 2);

    await model.removeAll();

    expect(model.todos, isEmpty);
    expect(model.todoCount, 0);
  });
}
