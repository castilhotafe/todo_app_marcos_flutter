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

  // These BREAD operations are completed in Session 6 Exercise 1.
  @override
  Future<bool> add(Todo model) => throw UnimplementedError();

  @override
  Future<bool> delete(Todo model) => throw UnimplementedError();

  @override
  Future<bool> edit(Todo model) => throw UnimplementedError();

  @override
  Future<Todo?> read(String id) => throw UnimplementedError();

  Future<void> close() => _database.close();
}
