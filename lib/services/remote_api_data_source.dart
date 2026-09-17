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
  Future<bool> add(Todo model) async {
    final reference = database.ref('todos').push();
    final id = reference.key;

    if (id == null) {
      return false;
    }

    final todo = Todo(
      id: id,
      name: model.name,
      description: model.description,
      complete: model.complete,
    );
    await reference.set(todo.toMap());
    return true;
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
  Future<bool> delete(Todo model) async {
    if (model.id.isEmpty) {
      return false;
    }

    await database.ref('todos/${model.id}').remove();
    return true;
  }

  @override
  Future<bool> edit(Todo model) async {
    if (model.id.isEmpty) {
      return false;
    }

    await database.ref('todos/${model.id}').set(model.toMap());
    return true;
  }

  @override
  Future<Todo?> read(String id) async {
    if (id.isEmpty) {
      return null;
    }

    final snapshot = await database.ref('todos/$id').get();
    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final values = Map<String, dynamic>.from(snapshot.value as Map);
    values['id'] = id;
    return Todo.fromMap(values);
  }
}
