import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_marcos/models/todo.dart';
import 'package:todo_app_marcos/models/todo_list.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';

import 'support/mock_data_source.dart';

void main() {
  late TodoList model;

  setUp(() {
    Get.put<IDataSource>(MockDataSource());
    model = TodoList();
  });

  tearDown(() {
    model.dispose();
    Get.reset();
  });

  testWidgets('Adding one Todo changes the counter from 0 to 1', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<TodoList>(
              builder: (context, list, child) {
                final pending = list.todos.where((todo) => !todo.complete).length;
                return Text('$pending to do');
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('0 to do'), findsOneWidget);

    await model.add(Todo(name: 'Read the lesson', description: 'Session 5'));
    await tester.pump();

    expect(find.text('1 to do'), findsOneWidget);
    expect(find.text('0 to do'), findsNothing);
  });
}
