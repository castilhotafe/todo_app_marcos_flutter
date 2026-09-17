import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';
import 'package:todo_app_marcos/models/todo.dart';

class TodoList extends ChangeNotifier {
  final List<Todo> _todos = [];

  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);
  int get todoCount => _todos.length;

  Future<void> refresh() async {
    final source = Get.find<IDataSource>();
    final saved = await source.browse();
    _todos.clear();
    _todos.addAll(saved);
    notifyListeners();
  }

  Future<void> add(Todo todo) async {
    final source = Get.find<IDataSource>();
    await source.add(todo);
    await refresh();
  }

  Future<void> removeAll() async {
    final source = Get.find<IDataSource>();
    for (final todo in List<Todo>.from(_todos)) {
      await source.delete(todo);
    }
    await refresh();
  }

  Future<void> remove(Todo todo) async {
    final source = Get.find<IDataSource>();
    await source.delete(todo);
    await refresh();
  }

  Future<void> updateTodo(Todo todo) async {
    final source = Get.find<IDataSource>();
    await source.edit(todo);
    await refresh();
  }
}
