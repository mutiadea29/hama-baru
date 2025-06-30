class Room {
  String id;
  String name;
  String description;
  int capacity;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
  });

  factory Room.fromMap(String id, Map<String, dynamic> data) {
    return Room(
      id: id,
      name: data['name'],
      description: data['description'],
      capacity: data['capacity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'capacity': capacity};
  }
}
