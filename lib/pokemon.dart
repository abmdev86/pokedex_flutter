// pokemon.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// ---- Simple in-memory caches (reset when the app restarts) ----
final Map<int, Pokemon> _pokemonCache = {};
final Map<String, List<Pokemon>> _pageCache = {};

/// Optional: de-duplicate concurrent requests (avoid double hits)
final Map<int, Future<Pokemon>> _inflightPokemon = {};
final Map<String, Future<List<Pokemon>>> _inflightPage = {};

/// Fetch a single Pokémon by id.
/// Uses in-memory cache and de-dupes in-flight requests.
Future<Pokemon> fetchPokemon(int id, {bool forceRefresh = false}) async {
  if (!forceRefresh && _pokemonCache.containsKey(id)) {
    return _pokemonCache[id]!;
  }
  if (!forceRefresh && _inflightPokemon.containsKey(id)) {
    return _inflightPokemon[id]!;
  }

  final future = _fetchPokemonFromNetwork(id);
  _inflightPokemon[id] = future;

  try {
    final p = await future;
    _pokemonCache[id] = p;
    return p;
  } finally {
    _inflightPokemon.remove(id);
  }
}

Future<Pokemon> _fetchPokemonFromNetwork(int id) async {
  final res = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'),
  );
  if (res.statusCode != 200) {
    throw Exception('Failed to load pokemon $id (${res.statusCode})');
  }
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  return Pokemon.fromJson(json);
}

/// Fetch a paginated list of Pokémon from PokeAPI.
/// Returns a List of type Pokemon built from the `{ results: [{name, url}] }` payload.
/// Cached per `limit/offset` for the lifetime of the app session.
Future<List<Pokemon>> fetchPokeList({
  int limit = 20,
  int offset = 0,
  bool forceRefresh = false,
}) async {
  final key = 'limit=$limit&offset=$offset';

  if (!forceRefresh && _pageCache.containsKey(key)) {
    return _pageCache[key]!;
  }
  if (!forceRefresh && _inflightPage.containsKey(key)) {
    return _inflightPage[key]!;
  }

  final future = _fetchPokeListFromNetwork(limit: limit, offset: offset);
  _inflightPage[key] = future;

  try {
    final list = await future;
    _pageCache[key] = list;
    return list;
  } finally {
    _inflightPage.remove(key);
  }
}

Future<List<Pokemon>> _fetchPokeListFromNetwork({
  required int limit,
  required int offset,
}) async {
  final uri = Uri.parse(
    'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
  );
  final res = await http.get(uri);
  if (res.statusCode != 200) {
    throw Exception('Failed to load pokemon list (${res.statusCode})');
  }

  final decoded = jsonDecode(res.body) as Map<String, dynamic>;
  final results = decoded['results'];
  if (results is! List) {
    throw const FormatException('Unexpected list response shape');
  }

  // Convert list items {name, url} -> Pokemon(id, name)
  return results
      .whereType<Map<String, dynamic>>()
      .map(Pokemon.fromListItem)
      .toList(growable: false);
}

/// Plain model with explicit parsing (prevents "Instance of ..." issues).
class Pokemon {
  final int id;
  final String name;

  const Pokemon({required this.id, required this.name});

  /// For /pokemon/{id} responses
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    return Pokemon(id: id, name: name);
  }

  /// For list items from `{ results: [ { name, url } ] }`
  factory Pokemon.fromListItem(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final url = json['url'] as String;
    final id =
        _extractIdFromUrl(url) ??
        (throw const FormatException('Could not extract id from url'));
    return Pokemon(id: id, name: name);
  }

  static int? _extractIdFromUrl(String url) {
    // Matches trailing number like .../pokemon/25/ -> 25
    final match = RegExp(r'/(\d+)/?$').firstMatch(url);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }
}

/// Optional helpers if you want to clear caches manually
void clearAllPokemonCaches() {
  _pokemonCache.clear();
  _pageCache.clear();
  _inflightPokemon.clear();
  _inflightPage.clear();
}
