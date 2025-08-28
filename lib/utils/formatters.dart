String formatId(int id) => '#${id.toString().padLeft(3, '0')}';
String officialArtworkUrl(int id) =>
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
