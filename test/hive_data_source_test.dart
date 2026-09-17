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

  test('BREAD retains generated Hive keys as Todo IDs', () async {
    expect(
      await source.add(
        Todo(id: '999', name: 'Learn Hive', description: 'First'),
      ),
      isTrue,
    );
    expect(
      await source.add(Todo(name: 'Learn Hive', description: 'Second')),
      isTrue,
    );

    final todos = await source.browse();
    expect(todos, hasLength(2));
    expect(todos[0].id, isNot('999'));
    expect(todos[0].id, isNot(todos[1].id));
    expect((await source.read(todos[0].id))!.description, 'First');
    expect(await source.read('not-a-hive-key'), isNull);

    final updated = Todo(
      id: todos[1].id,
      name: todos[1].name,
      description: 'Second, completed',
      complete: true,
    );
    expect(await source.edit(updated), isTrue);
    expect((await source.read(updated.id))!.complete, isTrue);
    expect(await source.delete(todos[0]), isTrue);
    expect(await source.delete(todos[0]), isFalse);

    await source.close();
    source = await HiveDataSource.createAsync(directoryPath: directory.path);
    final persisted = (await source.browse()).single;
    expect(persisted.id, updated.id);
    expect(persisted.description, 'Second, completed');
    expect(persisted.complete, isTrue);
  });
}
