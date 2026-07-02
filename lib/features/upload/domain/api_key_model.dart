class ApiKey {
  final String id;
  final String service;
  final String name;
  final String key;
  final String? description;
  final bool active;
  final DateTime createdAt;

  const ApiKey({
    required this.id,
    required this.service,
    required this.name,
    required this.key,
    this.description,
    required this.active,
    required this.createdAt,
  });

  ApiKey copyWith({
    String? id,
    String? service,
    String? name,
    String? key,
    String? description,
    bool? active,
    DateTime? createdAt,
  }) {
    return ApiKey(
      id: id ?? this.id,
      service: service ?? this.service,
      name: name ?? this.name,
      key: key ?? this.key,
      description: description ?? this.description,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
