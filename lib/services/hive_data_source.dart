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

  // These operations are completed in Session 7 Exercise 1.
  @override
  Future<bool> add(Todo model) => throw UnimplementedError();

  @override
  Future<bool> delete(Todo model) => throw UnimplementedError();

  @override
  Future<bool> edit(Todo model) => throw UnimplementedError();

  @override
  Future<Todo?> read(String id) => throw UnimplementedError();

  Future<void> close() => _box.close();
}
