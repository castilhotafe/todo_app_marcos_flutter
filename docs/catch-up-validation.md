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

## Session 7 — Hive initialisation and browse

- Added the awaited Hive factory, adapter registration, typed `todos` box and
  browse implementation behind the existing IDataSource contract.
- A real Hive storage test wrote a Todo, closed the data source, reopened it and
  retrieved the saved Todo through `browse()`.

## Session 7 — Exercise 1: Hive BREAD and IDs

- Add now uses Hive's generated integer key, stores that key in `Todo.id`, then
  uses the ID for read, edit and delete.
- Real Hive tests cover duplicate names, generated IDs, missing IDs, editing,
  deletion and persistence after closing/reopening the box.
- The app registration now supplies HiveDataSource through the same IDataSource
  contract already used by TodoList and Provider.
- A TodoList integration test verified add, edit, refresh after reopening Hive,
  and delete. Final Session 7 validation: `flutter analyze` reported no issues
  and all tests passed.
- Manual macOS validation passed: a Todo persisted after restart, its completed
  state persisted after another restart, and a swiped deletion remained deleted
  after reopening the app.

## Session 8 — Firebase Realtime Database

- Added the current `firebase_core` and `firebase_database` packages requested by
  the tutorial and initialized Firebase with the supplied platform options.
- The supplied Firebase project, rules and generated options files are present
  locally but explicitly ignored by Git. None of them is tracked.
- Browse converts the remote `todos` map into Todo objects and uses each Firebase
  child key as the Todo ID. As directed by the tutorial, a missing `todos`
  snapshot throws an exception because the expected shared structure is absent.
- Add uses `push()` and writes one complete Todo beneath its generated child key.
  Read, edit and delete address only `todos/<id>`, and edit writes all four fields
  required by the supplied database structure.
- The app now registers RemoteAPIDataSource through the existing IDataSource
  contract before TodoList performs its initial refresh.
- Static analysis found no issues, all 11 existing tests passed, and the Web
  release build completed. A real Web run initialized Firebase and displayed the
  existing remote Todos and pending count without changing shared records.
- Manual Chrome validation passed against the supplied Firebase project: a new
  Todo persisted after reload, its completed state persisted after another
  reload, and after swipe deletion it remained deleted after reloading again.
- The material instructs students to download preconfigured Firebase files from
  Blackboard. The remote project and its active security rules are therefore
  treated as supplied course infrastructure, outside the student's
  administration responsibilities. No Firebase configuration or rules were
  deployed or changed during this work.
