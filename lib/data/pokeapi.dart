import 'dart:convert';

import 'package:http/http.dart' as http;

import 'pokemon.dart';

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

Future<Pokemon> _fetchPokemonFromNetwork(int id, {http.Client? client}) async {
  client ??= http.Client();
  final res = await client.get(
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

// returns a list of Pokemon {name, id}
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

void clearAllPokemonCaches() {
  _pokemonCache.clear();
  _pageCache.clear();
  _inflightPokemon.clear();
  _inflightPage.clear();
}
