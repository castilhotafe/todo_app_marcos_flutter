import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:todo_app_marcos/firebase_options.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';

class RemoteAPIDataSource implements IDataSource {
  late FirebaseDatabase database;

  Future<void> initialise() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    database = FirebaseDatabase.instance;
  }

  static Future<RemoteAPIDataSource> createAsync() async {
    final dataSource = RemoteAPIDataSource();
    await dataSource.initialise();
    return dataSource;
  }

  @override
  Future<bool> add(Todo model) {
    throw UnimplementedError();
  }

  @override
  Future<List<Todo>> browse() async {
    final snapshot = await database.ref('todos').get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final todoMap = Map<Object?, Object?>.from(snapshot.value as Map);
    final todos = <Todo>[];

    for (final entry in todoMap.entries) {
      final values = Map<String, dynamic>.from(entry.value as Map);
      values['id'] = entry.key.toString();
      todos.add(Todo.fromMap(values));
    }

    return todos;
  }

  @override
  Future<bool> delete(Todo model) {
    throw UnimplementedError();
  }

  @override
  Future<bool> edit(Todo model) {
    throw UnimplementedError();
  }

  @override
  Future<Todo?> read(String id) {
    throw UnimplementedError();
  }
}
