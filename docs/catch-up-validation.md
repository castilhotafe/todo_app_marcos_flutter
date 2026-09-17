# Catch-up validation

Only observations and tests actually completed are recorded here. The original
Session 5 baseline remains `3e8aa90`; session branches are cumulative.

## Session 5 — Provider

- Exercise 4: the user ran the app and confirmed the four requested behaviours:
  add two Todos (count 2), complete one (count 1), dismiss the pending Todo
  (count 0), and dismiss the remaining Todo (empty list).
- The existing decorative NetworkImage failed with a SocketException / Operation
  not permitted during the user's run. Its code and URL were not changed.
- Automated widget test: real add-dialog actions, checkbox action, swipe actions,
  displayed counts and remaining items all passed. Only the decorative image was
  supplied locally in the test; no Todo state behaviour was mocked.
- Model test: removeAll empties the list and notifies listeners once; passed.
- `flutter test`: 2 passed. `flutter analyze`: no issues found.
- Test runtime: Flutter 3.44.8 / Dart 3.12.2, using a workspace copy of the existing
  SDK because this environment cannot write to the installed SDK cache.
- The user's execution platform was not specified. These observations are not
  evidence of both emulator and physical-device testing for the assessment.

## Pending assessment evidence

- Sessions 6–9 persistence, binary storage, remote API and connectivity tests.
- Database structure change demonstration, tracing/runtime values, emulator and
  physical-device execution.
- Appendix A device specifications were not supplied in the reference materials.

## Session 6 — Datasource Interface

- Added the tutorial's asynchronous IDataSource BREAD contract. `read` can return
  null when no Todo has the requested ID. No database or new package is present
  at this checkpoint, and the app still uses its Session 5 in-memory model.
- Formatting passed; `flutter analyze`: no issues; existing `flutter test`: 2
  passed. This validates the contract's compilation and the unchanged app, not
  SQLite persistence.
- Native runtime checks are not yet usable from this environment: Flutter doctor
  reported Xcode setup issues and no mobile emulators, and CoreSimulator requests
  failed with connection/permission errors. These checks do not establish whether
  the user's IDE can run a native target outside this environment.

## Session 6 — SQLite initialisation and mapping

- The user confirmed that the pre-SQLite app built and opened on macOS outside
  the agent's restricted build environment. This establishes a native target,
  not yet SQLite behaviour in that app.
- Added the SQLite file/table, awaited construction, Todo ID and map conversions,
  and browse. The remaining BREAD methods are explicitly unfinished at this
  learning checkpoint and are not yet connected to the UI.
- Actual SQLite host tests verified table columns, file creation, reading a saved
  row after closing/reopening, generated ID, and bool/integer conversion.
- Tests use sqflite_common_ffi as a development-only backend, as documented by
  its maintainer: https://pub.dev/packages/sqflite_common_ffi . This is real SQL
  and file storage, but does not certify the native sqflite plugin integration.
- `flutter test`: 4 passed. `flutter analyze`: no issues found.

## Session 6 — Exercise 1: BREAD

- Implemented add/read/edit/delete against SQLite with parameterised IDs.
- Tests verified generated IDs (ignoring an input ID when inserting), separate
  records with identical names, apostrophes in text, editing just the selected ID,
  missing-record results, and saved edits/deletions after closing/reopening.
- `flutter test`: 5 passed using actual SQLite files on the host.
  `flutter analyze`: no issues. Native UI integration remains a later step.

## Session 6 — Get, refresh and Exercise 2

- Registered the awaited SQLite data source with Get before starting the app.
- `TodoList.refresh()` browses the registered source, replaces the in-memory
  list and notifies Provider consumers. A RefreshIndicator exposes this action.
- TodoList add, update, delete and removeAll now call the registered source and
  refresh the UI from SQLite. Checkbox updates preserve the database ID.
- A real SQLite model test verified registration, refresh, add, edit, delete and
  reopening the database. Widget tests verified the add dialog, count, checkbox,
  swipe deletion and removeAll through the data-source interface.
- Final validation: `flutter analyze` reported no issues and all 7 tests passed.
- The widget test uses a small in-memory IDataSource so widget timing does not
  depend on native file I/O. SQLite behaviour is covered separately with actual
  temporary database files.
- Manual macOS validation passed after SQLite integration: the user created a
  Todo through the UI, closed the app, reopened it and confirmed the Todo was
  restored. The pre-existing NetworkImage still failed to load, while SQLite
  persistence behaved correctly.

## Session 7 — Hive adapter

- Added the HiveType/HiveField annotations and the manual TodoAdapter shown by
  the tutorial, with stable field numbers for ID, name, description and status.
- A real Hive box test wrote the binary object, closed the box, reopened it and
  recovered every Todo field correctly.
- `flutter analyze`: no issues. Todo adapter test: passed.
