import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app_marcos/models/todo.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('todo_hive_adapter_');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'TodoAdapter writes and reads every Todo field as binary data',
    () async {
      var box = await Hive.openBox<Todo>('todos');
      await box.add(
        Todo(
          id: '42',
          name: 'Learn Hive',
          description: 'Session 7',
          complete: true,
        ),
      );
      await box.close();

      box = await Hive.openBox<Todo>('todos');
      final saved = box.values.single;
      expect(saved.id, '42');
      expect(saved.name, 'Learn Hive');
      expect(saved.description, 'Session 7');
      expect(saved.complete, isTrue);
    },
  );
}
