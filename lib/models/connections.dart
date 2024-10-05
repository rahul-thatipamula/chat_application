class Connections {
  final String id;
  final String name;

  Connections({required this.id, required this.name});

  // Create a User object from a Firestore document
  factory Connections.fromJson(Map<String, dynamic> data, String id) {
    return Connections(
      id: id,
      name: data['name'] as String,
    );
  }
}
