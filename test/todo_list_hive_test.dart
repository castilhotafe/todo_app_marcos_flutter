import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/models/todo_list.dart';
import 'package:todo_app_marcos/services/hive_data_source.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';

void main() {
  late Directory directory;
  late HiveDataSource source;
  late TodoList model;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('todo_hive_model_');
    source = await HiveDataSource.createAsync(directoryPath: directory.path);
    Get.put<IDataSource>(source);
    model = TodoList();
  });

  tearDown(() async {
    model.dispose();
    Get.reset();
    await source.close();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('TodoList persists add, edit and delete through Hive', () async {
    await model.add(Todo(name: 'Hive task', description: 'Session 7'));
    final saved = model.todos.single;
    expect(saved.id, isNotEmpty);

    await model.updateTodo(
      Todo(
        id: saved.id,
        name: saved.name,
        description: saved.description,
        complete: true,
      ),
    );
    expect(model.todos.single.complete, isTrue);

    await source.close();
    source = await HiveDataSource.createAsync(directoryPath: directory.path);
    Get.replace<IDataSource>(source);
    await model.refresh();
    expect(model.todos.single.id, saved.id);
    expect(model.todos.single.complete, isTrue);

    await model.remove(model.todos.single);
    expect(model.todos, isEmpty);
  });
}
