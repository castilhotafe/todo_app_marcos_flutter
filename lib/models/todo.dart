class Todo {
  final String id;
  final String name;
  final String description;
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
