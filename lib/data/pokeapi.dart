import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pokedex_flutter/data/reference_object.dart';

import 'pokemon.dart';

/// ---- Simple in-memory caches (reset when the app restarts) ----
final Map<int, Pokemon> _pokemonCache = {};
final Map<String, List<Pokemon>> _pageCache = {};

/// Optional: de-duplicate concurrent requests (avoid double hits)
final Map<int, Future<Pokemon>> _inflightPokemon = {};
final Map<String, Future<List<Pokemon>>> _inflightPage = {};

/// Fetch a single Pokémon by id.
/// Uses in-memory cache and de-dupes in-flight requests.
Future<Pokemon> fetchPokemon(
  int id, {
  bool forceRefresh = false,
  http.Client? client,
}) async {
  if (!forceRefresh && _pokemonCache.containsKey(id)) {
    return _pokemonCache[id]!;
  }
  if (!forceRefresh && _inflightPokemon.containsKey(id)) {
    return _inflightPokemon[id]!;
  }

  final future = _fetchPokemonFromNetwork(id, client: client);
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
  http.Client? client,
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

Future<dynamic> fetchFromReferenceObject(
  ReferenceObject ref, {
  http.Client? client,
}) async {
  final response =
      await client?.get(Uri.parse(ref.url)) ??
      await http.get(Uri.parse(ref.url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Pokemon.fromJson(data);
  } else {
    throw Exception('Failed to load Pokemon data');
  }
}

Future<Pokemon> fromListItem(Map<String, dynamic> json) async {
  final name = json['name'] as String;
  final url = json['url'] as String;

  return await fetchFromReferenceObject(ReferenceObject(name: name, url: url));
}

// returns a list of Pokemon {name, id}
Future<List<Pokemon>> _fetchPokeListFromNetwork({
  required int limit,
  required int offset,
  http.Client? client,
}) async {
  client ??= http.Client();
  final uri = Uri.parse(
    'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
  );
  final res = await client.get(uri);
  if (res.statusCode != 200) {
    throw Exception('Failed to load pokemon list (${res.statusCode})');
  }

  final decoded = jsonDecode(res.body) as Map<String, dynamic>;
  final results = decoded['results'];
  if (results is! List) {
    throw const FormatException('Unexpected list response shape');
  }

  // Convert list items {name, url} -> Pokemon(id, name)
  final pokemons = await Future.wait(
    (results).map((item) => fromListItem(item as Map<String, dynamic>)),
  );
  return pokemons;
}

void clearAllPokemonCaches() {
  _pokemonCache.clear();
  _pageCache.clear();
  _inflightPokemon.clear();
  _inflightPage.clear();
}
