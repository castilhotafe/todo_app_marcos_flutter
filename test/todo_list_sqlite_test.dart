import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/models/todo_list.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';
import 'package:todo_app_marcos/services/sqlite_data_source.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory directory;
  late SQLiteDataSource source;
  late TodoList model;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('todo_model_test_');
    await Get.putAsync<IDataSource>(() async {
      source = await SQLiteDataSource.createAsync(
        databasePath: join(directory.path, 'todos.db'),
      );
      return source;
    });
    model = TodoList();
  });

  tearDown(() async {
    model.dispose();
    Get.reset();
    await source.close();
    await directory.delete(recursive: true);
  });

  test(
    'Refresh resolves the ready data source and notifies its consumers',
    () async {
      expect(Get.find<IDataSource>(), same(source));
      await source.add(Todo(name: 'Saved task', description: 'SQLite'));
      var notifications = 0;
      model.addListener(() => notifications++);
      await model.refresh();
      expect(model.todoCount, 1);
      expect(model.todos.single.name, 'Saved task');
      expect(model.todos.single.id, isNotEmpty);
      expect(notifications, 1);

      // Refresh reads external changes, rather than appending duplicate rows.
      await source.delete(model.todos.single);
      await model.refresh();
      expect(model.todoCount, 0);
      expect(notifications, 2);
    },
  );

  test(
    'TodoList additions, edits and deletions persist through SQLite',
    () async {
      await model.add(Todo(name: 'Saved task', description: 'Session 6'));
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

      await model.remove(model.todos.single);
      expect(model.todos, isEmpty);

      await source.close();
      source = await SQLiteDataSource.createAsync(
        databasePath: join(directory.path, 'todos.db'),
      );
      Get.replace<IDataSource>(source);
      await model.refresh();
      expect(model.todos, isEmpty);
    },
  );
}
