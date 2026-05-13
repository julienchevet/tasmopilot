class Site {
  final int? id;
  final String name;
  final DateTime createdAt;

  const Site({
    this.id,
    required this.name,
    required this.createdAt,
  });

  // Convert a Site into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert a Map into a Site.
  factory Site.fromMap(Map<String, dynamic> map) {
    return Site(
      id: map['id'] as int,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Site copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Site(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
