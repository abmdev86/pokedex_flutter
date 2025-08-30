// pokemon.dart

/// Plain model with explicit parsing (prevents "Instance of ..." issues).
class Pokemon {
  final int id;
  final String name;
  final double baseExp;

  const Pokemon({required this.id, required this.name, this.baseExp = 0});

  /// For /pokemon/{id} responses
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final baseExp = json['base_experience'] as double;
    return Pokemon(id: id, name: name, baseExp: baseExp);
  }

  /// For list items from `{ results: [ { name, url } ] }`
  factory Pokemon.fromListItem(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final url = json['url'] as String;
    final baseExp = json['base_experience'] as double;
    final id =
        _extractIdFromUrl(url) ??
        (throw const FormatException('Could not extract id from url'));
    return Pokemon(id: id, name: name, baseExp: baseExp);
  }

  static int? _extractIdFromUrl(String url) {
    // Matches trailing number like .../pokemon/25/ -> 25
    final match = RegExp(r'/(\d+)/?$').firstMatch(url);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }
}

/// Optional helpers if you want to clear caches manually
