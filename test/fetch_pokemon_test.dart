import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pokedex_flutter/data/pokeapi.dart';
import 'package:pokedex_flutter/data/reference_object.dart';
import 'fetch_pokemon_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('fetchPokemon', () {
    setUp(() {
      clearAllPokemonCaches();
    });

    test('fetch from ReferenceObject', () async {
      final client = MockClient();
      final ref = ReferenceObject(
        name: 'bulbasaur',
        url: 'https://pokeapi.co/api/v2/pokemon/1',
      );

      when(client.get(Uri.parse(ref.url))).thenAnswer(
        (_) async => http.Response('{"id": 1, "name": "bulbasaur"}', 200),
      );

      final pokemon = await fetchFromReferenceObject(ref, client: client);
      expect(pokemon.id, 1);
      expect(pokemon.name, 'bulbasaur');
    });

    test('returns a Pokemon if successful', () async {
      final client = MockClient();
      when(
        client.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1')),
      ).thenAnswer(
        (_) async => http.Response('{"id": 1, "name": "bulbasaur"}', 200),
      );

      final pokemon = await fetchPokemon(1, client: client);
      expect(pokemon.id, 1);
      expect(pokemon.name, 'bulbasaur');
    });
    test('Throws exception if http call throws error', () async {
      final client = MockClient();
      clearAllPokemonCaches();

      when(
        client.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1')),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () async => await fetchPokemon(1, client: client),
        throwsException,
      );
    });

    test('Uses cache if available', () async {
      final client = MockClient();
      clearAllPokemonCaches();

      when(
        client.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1')),
      ).thenAnswer(
        (_) async => http.Response('{"id": 1, "name": "bulbasaur"}', 200),
      );

      // First call fetches from network
      final pokemon1 = await fetchPokemon(1, client: client);
      expect(pokemon1.id, 1);
      expect(pokemon1.name, 'bulbasaur');

      // Clear interactions to verify no further network calls
      clearInteractions(client);

      // Second call should use cache
      final pokemon2 = await fetchPokemon(1, client: client);
      expect(pokemon2.id, 1);
      expect(pokemon2.name, 'bulbasaur');

      // Verify no network calls were made on the second fetch
      verifyNever(client.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1')));
    });

    test('Fetch 1 Pokemon from Poke List', () async {
      final client = MockClient();
      final int limit = 5;
      final int offset = 0;
      clearAllPokemonCaches();

      when(
        client.get(
          Uri.parse(
            'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"results": [{"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1"}, {"name": "ivysaur", "url": "https://pokeapi.co/api/v2/pokemon/2"}, {"name": "venusaur", "url": "https://pokeapi.co/api/v2/pokemon/3"}, {"name": "charmander", "url": "https://pokeapi.co/api/v2/pokemon/4"}, {"name": "charmeleon", "url": "https://pokeapi.co/api/v2/pokemon/5"}]}',
          200,
        ),
      );

      final pokemonList = await fetchPokeList(
        client: client,
        limit: limit,
        offset: offset,
      );
      expect(pokemonList.length, 5);
      expect(pokemonList[0].id, 1);
      expect(pokemonList[1].id, 2);
      expect(pokemonList[2].id, 3);
      expect(pokemonList[3].id, 4);
      expect(pokemonList[4].id, 5);
      expect(pokemonList[0].name, 'bulbasaur');
      expect(pokemonList[1].name, 'ivysaur');
      expect(pokemonList[2].name, 'venusaur');
      expect(pokemonList[3].name, 'charmander');
      expect(pokemonList[4].name, 'charmeleon');
    });

    test('Uses cache when fetching Poke List', () async {
      final client = MockClient();
      final int limit = 5;
      final int offset = 0;
      clearAllPokemonCaches();

      when(
        client.get(
          Uri.parse(
            'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"results": [{"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1"}, {"name": "ivysaur", "url": "https://pokeapi.co/api/v2/pokemon/2"}, {"name": "venusaur", "url": "https://pokeapi.co/api/v2/pokemon/3"}, {"name": "charmander", "url": "https://pokeapi.co/api/v2/pokemon/4"}, {"name": "charmeleon", "url": "https://pokeapi.co/api/v2/pokemon/5"}]}',
          200,
        ),
      );

      // First call fetches from network
      final pokemonList1 = await fetchPokeList(
        client: client,
        limit: limit,
        offset: offset,
      );
      expect(pokemonList1.length, 5);
      expect(pokemonList1[0].id, 1);
      expect(pokemonList1[1].id, 2);
      expect(pokemonList1[2].id, 3);
      expect(pokemonList1[3].id, 4);
      expect(pokemonList1[4].id, 5);
      expect(pokemonList1[0].name, 'bulbasaur');
      expect(pokemonList1[1].name, 'ivysaur');
      expect(pokemonList1[2].name, 'venusaur');
      expect(pokemonList1[3].name, 'charmander');
      expect(pokemonList1[4].name, 'charmeleon');

      // Clear interactions to verify no further network calls
      clearInteractions(client);

      // Second call should use cache
      final pokemonList2 = await fetchPokeList(
        client: client,
        limit: limit,
        offset: offset,
      );
      expect(pokemonList2.length, 5);
      expect(pokemonList2[0].name, 'bulbasaur');
      expect(pokemonList2[1].name, 'ivysaur');
      expect(pokemonList2[2].name, 'venusaur');
      expect(pokemonList2[3].name, 'charmander');
      expect(pokemonList2[4].name, 'charmeleon');
    });
  });

  tearDown(() {
    clearAllPokemonCaches();
  });
}
