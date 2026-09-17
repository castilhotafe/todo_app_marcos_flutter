import 'package:todo_app_marcos/models/todo.dart';

// BREAD: Browse, Read, Edit, Add and Delete.
// Futures let each data source finish its storage work asynchronously.
abstract class IDataSource {
  Future<List<Todo>> browse();
  Future<Todo?> read(String id);
  Future<bool> edit(Todo model);
  Future<bool> add(Todo model);
  Future<bool> delete(Todo model);
}
