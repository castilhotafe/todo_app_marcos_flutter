import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';

class SQLiteDataSource implements IDataSource {
  late Database _database;

  Future<void> initialise({String? databasePath}) async {
    final path =
        databasePath ?? join(await getDatabasesPath(), 'todo_database.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE todos (id INTEGER PRIMARY KEY, name TEXT, '
          'description TEXT, complete INTEGER)',
        );
      },
    );
  }

  static Future<SQLiteDataSource> createAsync({String? databasePath}) async {
    final source = SQLiteDataSource();
    await source.initialise(databasePath: databasePath);
    return source;
  }

  @override
  Future<List<Todo>> browse() async {
    final rows = await _database.query('todos');
    return rows.map((row) => Todo.fromMap(row)).toList();
  }

  @override
  Future<bool> add(Todo model) async {
    final values = model.toMap();
    values.remove('id');
    final id = await _database.insert('todos', values);
    return id > 0;
  }

  @override
  Future<bool> delete(Todo model) async {
    final count = await _database.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [model.id],
    );
    return count == 1;
  }

  @override
  Future<bool> edit(Todo model) async {
    final values = model.toMap();
    values.remove('id');
    final count = await _database.update(
      'todos',
      values,
      where: 'id = ?',
      whereArgs: [model.id],
    );
    return count == 1;
  }

  @override
  Future<Todo?> read(String id) async {
    final rows = await _database.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Todo.fromMap(rows.first);
  }

  Future<void> close() => _database.close();
}
