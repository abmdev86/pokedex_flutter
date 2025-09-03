// pokemon.dart

import 'reference_object.dart';

/// Plain model with explicit parsing (prevents "Instance of ..." issues).
class Pokemon {
  final int id;
  final String name;
  final int baseExp;
  final int height;
  final int weight;
  final List<dynamic> abilities;
  final List<ReferenceObject> types;

  const Pokemon({
    required this.id,
    required this.name,
    this.baseExp = 0,
    this.height = 0,
    this.weight = 0,
    this.abilities = const [],
    this.types = const [],
  });

  String get listAbilities => abilities.map((a) => a.name).join(', ');
  String get listTypes => types.map((t) => t.name).join(', ');

  /// For /pokemon/{id} responses
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final baseExp = json['base_experience'] ?? 0;
    final height = json['height'] ?? 0;
    final weight = json['weight'] ?? 0;
    final List<ReferenceObject> abilities = parseReferenceObjects(
      json,
      'abilities',
    );

    final List<ReferenceObject> types = parseReferenceObjects(json, 'types');

    return Pokemon(
      id: id,
      name: name,
      baseExp: baseExp,
      height: height,
      weight: weight,
      abilities: abilities,
      types: types,
    );
  }
}

/// Optional helpers if you want to clear caches manually
