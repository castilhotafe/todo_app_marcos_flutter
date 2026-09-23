import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';

// In-memory test data; the application still uses its real data source.
class MockDataSource implements IDataSource {
  final List<Todo> _todos = [];
  int _nextId = 1;

  @override
  Future<bool> add(Todo model) async {
    _todos.add(
      Todo(
        id: (_nextId++).toString(),
        name: model.name,
        description: model.description,
        complete: model.complete,
      ),
    );
    return true;
  }

  @override
  Future<List<Todo>> browse() async => List<Todo>.from(_todos);

  @override
  Future<bool> delete(Todo model) async {
    final length = _todos.length;
    _todos.removeWhere((todo) => todo.id == model.id);
    return _todos.length < length;
  }

  @override
  Future<bool> edit(Todo model) async {
    final index = _todos.indexWhere((todo) => todo.id == model.id);
    if (index == -1) {
      return false;
    }
    _todos[index] = model;
    return true;
  }

  @override
  Future<Todo?> read(String id) async {
    for (final todo in _todos) {
      if (todo.id == id) {
        return todo;
      }
    }
    return null;
  }
}
