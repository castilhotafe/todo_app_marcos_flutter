import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_marcos/main.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/models/todo_list.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';

void main() {
  late _MemoryDataSource source;

  setUp(() {
    source = _MemoryDataSource();
    Get.put<IDataSource>(source);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Adding, completing and dismissing Todos updates the count', (
    tester,
  ) async {
    // Supply only the decorative image locally so this test needs no Internet.
    final frame = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGP4DwQACfsD/fteaysAAAAASUVORK5CYII=',
        ),
      );
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame;
    });
    const background = NetworkImage(
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROzcg6lJRaznvAJzAq2Z6F9x_u6eLaid0WjPPqRGNSndCTP4uScTUlu0PL&s=10',
    );
    PaintingBinding.instance.imageCache.putIfAbsent(
      background,
      () => OneFrameImageStreamCompleter(
        Future.value(ImageInfo(image: frame!.image)),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => TodoList(), child: const TodoApp()),
    );
    expect(find.text('0 to do'), findsOneWidget);

    for (final name in ['Read the lesson', 'Practise Flutter']) {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, name);
      await tester.enterText(find.byType(TextFormField).last, 'Session 5');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();
    }
    expect(find.text('2 to do'), findsOneWidget);
    expect(find.byType(Dismissible), findsNWidgets(2));

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('1 to do'), findsOneWidget);

    await tester.drag(find.byType(Dismissible).last, const Offset(-800, 0));
    await tester.pumpAndSettle();
    expect(find.text('Practise Flutter'), findsNothing);
    expect(find.text('Read the lesson'), findsOneWidget);
    expect(find.text('0 to do'), findsOneWidget);

    await tester.drag(find.byType(Dismissible).first, const Offset(800, 0));
    await tester.pumpAndSettle();
    expect(find.byType(Dismissible), findsNothing);
    expect(find.text('0 to do'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('removeAll empties the model and notifies listeners', () async {
    final model = TodoList();
    await model.add(Todo(name: 'Read', description: 'Lesson'));
    await model.add(Todo(name: 'Practise', description: 'Exercise'));
    var notifications = 0;
    model.addListener(() => notifications++);
    await model.removeAll();
    expect(model.todos, isEmpty);
    expect(model.todoCount, 0);
    expect(notifications, 1);
    expect(await source.browse(), isEmpty);
    model.dispose();
  });
}

class _MemoryDataSource implements IDataSource {
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
