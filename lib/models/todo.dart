class Todo {
  final String name;
  final String description;
  final bool complete;

  Todo({
    required this.name,
    required this.description,
    this.complete = false,
  });

  @override
  String toString() {
    return '$name - $description';
  }
}
