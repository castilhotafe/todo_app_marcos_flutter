import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/services/sqlite_data_source.dart';

void main() {
  // Use the real SQLite engine in host tests. The app uses the sqflite plugin.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory directory;
  late String path;
  late SQLiteDataSource source;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('todo_sqlite_test_');
    path = join(directory.path, 'todos.db');
    source = await SQLiteDataSource.createAsync(databasePath: path);
  });

  tearDown(() async {
    await source.close();
    await directory.delete(recursive: true);
  });

  test('Creates a SQLite table and reads saved rows after reopening', () async {
    expect(await source.browse(), isEmpty);
    expect(await File(path).exists(), isTrue);
    final db = await databaseFactory.openDatabase(path);
    final columns = await db.rawQuery('PRAGMA table_info(todos)');
    expect(columns.map((column) => column['name']), [
      'id',
      'name',
      'description',
      'complete',
    ]);
    await db.insert('todos', {
      'name': 'Read SQLite',
      'description': 'Session 6',
      'complete': 1,
    });
    await source.close();
    source = await SQLiteDataSource.createAsync(databasePath: path);
    final todo = (await source.browse()).single;
    expect(todo.id, '1');
    expect(todo.name, 'Read SQLite');
    expect(todo.description, 'Session 6');
    expect(todo.complete, isTrue);
  });

  test('Maps booleans to SQL integers and reads both supported formats', () {
    final todo = Todo(
      id: '9',
      name: 'Read',
      description: 'Mapping',
      complete: true,
    );
    expect(todo.toMap()['complete'], 1);
    expect(Todo.fromMap(todo.toMap()).id, '9');
    for (final value in [true, 1]) {
      expect(
        Todo.fromMap({...todo.toMap(), 'complete': value}).complete,
        isTrue,
      );
    }
    for (final value in [false, 0, null]) {
      expect(
        Todo.fromMap({...todo.toMap(), 'complete': value}).complete,
        isFalse,
      );
    }
  });
}
