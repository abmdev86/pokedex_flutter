import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pokedex_flutter/data/pokeapi.dart';
import 'fetch_pokemon_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('fetchPokemon', () {
    test('returns a Pokemon if successful', () async {
      final client = MockClient();
      clearAllPokemonCaches();
      when(
        client.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1')),
      ).thenAnswer(
        (_) async => http.Response('{"id": 1, "name": "bulbasaur"}', 200),
      );

      final pokemon = await fetchPokemon(1, client: client);
      expect(pokemon.id, 1);
      expect(pokemon.name, 'bulbasaur');
    });
  });

  test('Throws exception if http call throws error', () async {
    final client = MockClient();
    clearAllPokemonCaches();

    when(
      client.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1')),
    ).thenAnswer((_) async => http.Response('Not Found', 404));

    expect(() async => await fetchPokemon(1, client: client), throwsException);
  });
}
