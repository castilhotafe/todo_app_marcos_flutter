import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool complete;

  Todo({
    this.id = '',
    required this.name,
    required this.description,
    this.complete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'complete': complete ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'].toString(),
      name: map['name'] as String,
      description: map['description'] as String,
      complete: map['complete'] == true || map['complete'] == 1,
    );
  }

  @override
  String toString() {
    return '$name - $description';
  }
}

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    return Todo(
      id: reader.read() as String,
      name: reader.read() as String,
      description: reader.read() as String,
      complete: reader.read() as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.description);
    writer.write(obj.complete);
  }
}
