import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_marcos/main.dart';
import 'package:todo_app_marcos/models/todo_list.dart';
import 'package:todo_app_marcos/services/i_data_source.dart';

import 'support/mock_data_source.dart';

void main() {
  late MockDataSource source;

  setUp(() {
    source = MockDataSource();
    Get.put<IDataSource>(source);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Adding one Todo changes the counter from 0 to 1', (
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

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Read the lesson');
    await tester.enterText(find.byType(TextFormField).last, 'Session 5');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('1 to do'), findsOneWidget);
    expect(find.text('0 to do'), findsNothing);
  });
}
