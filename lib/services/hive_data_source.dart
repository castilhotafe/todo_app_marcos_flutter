import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';

class HiveDataSource implements IDataSource {
  late Box<Todo> _box;

  Future<void> initialise({String? directoryPath}) async {
    if (directoryPath == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(directoryPath);
    }

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }
    _box = await Hive.openBox<Todo>('todos');
  }

  static Future<HiveDataSource> createAsync({String? directoryPath}) async {
    final source = HiveDataSource();
    await source.initialise(directoryPath: directoryPath);
    return source;
  }

  @override
  Future<List<Todo>> browse() async {
    return _box.values.toList();
  }

  @override
  Future<bool> add(Todo model) async {
    final key = await _box.add(model);
    final saved = Todo(
      id: key.toString(),
      name: model.name,
      description: model.description,
      complete: model.complete,
    );
    await _box.put(key, saved);
    return true;
  }

  @override
  Future<bool> delete(Todo model) async {
    final key = int.tryParse(model.id);
    if (key == null || !_box.containsKey(key)) {
      return false;
    }
    await _box.delete(key);
    return true;
  }

  @override
  Future<bool> edit(Todo model) async {
    final key = int.tryParse(model.id);
    if (key == null || !_box.containsKey(key)) {
      return false;
    }
    await _box.put(key, model);
    return true;
  }

  @override
  Future<Todo?> read(String id) async {
    final key = int.tryParse(id);
    return key == null ? null : _box.get(key);
  }

  Future<void> close() => _box.close();
}
