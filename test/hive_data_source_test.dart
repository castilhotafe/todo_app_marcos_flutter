import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/services/hive_data_source.dart';

void main() {
  late Directory directory;
  late HiveDataSource source;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('todo_hive_source_');
    source = await HiveDataSource.createAsync(directoryPath: directory.path);
  });

  tearDown(() async {
    await source.close();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('Opens a typed Hive box and browses saved Todos', () async {
    expect(await source.browse(), isEmpty);
    await Hive.box<Todo>(
      'todos',
    ).add(Todo(id: '7', name: 'Read Hive', description: 'Session 7'));

    await source.close();
    source = await HiveDataSource.createAsync(directoryPath: directory.path);
    final saved = (await source.browse()).single;
    expect(saved.id, '7');
    expect(saved.name, 'Read Hive');
    expect(saved.description, 'Session 7');
    expect(saved.complete, isFalse);
  });
}
