class ReferenceObject {
  final String name;
  final String url;

  ReferenceObject({required this.name, required this.url});

  /// For nested objects like "type" and "ability"
  factory ReferenceObject.fromJson(Map<String, dynamic> json) {
    return ReferenceObject(name: json['name'], url: json['url']);
  }
}

// Helper to parse lists of ReferenceObject from a given key (e.g. 'types', 'abilities')
List<ReferenceObject> parseReferenceObjects(
  Map<String, dynamic> json,
  String key,
) {
  final list = json[key] as List<dynamic>? ?? [];
  return list
      .map(
        (item) =>
            ReferenceObject.fromJson(item['type'] ?? item['ability'] ?? item),
      )
      .toList();
}
