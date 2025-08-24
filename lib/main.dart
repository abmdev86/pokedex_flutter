import 'package:flutter/material.dart';
import 'pokemon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeFlutterdex',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 207, 20, 26),
        ),
      ),
      home: const MyHomePage(title: 'Pokedex HOME'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  final List<Pokemon> _items = [];
  int _pageIndex = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;

  // late Future<Pokemon> futurePokemon;
  late Future<List<Pokemon>> futureList;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
    // futurePokemon = fetchPokemon(1);
    // futureList = fetchPokeList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || !_hasMore) return;

    // load next page within 200 px of the bottom
    final threshold = 200.0;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore({bool forceRefresh = false}) async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final offset = _pageIndex * _limit;
      final newPage = await fetchPokeList(
        limit: _limit,
        offset: offset,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;

      setState(() {
        _items.addAll(newPage);
        _pageIndex += 1;
        if (newPage.length < _limit) _hasMore = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    // Optional pull-to-refresh: clear and reload from page 0
    setState(() {
      _items.clear();
      _pageIndex = 0;
      _hasMore = true;
    });
    await _loadMore(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh, // pull down to force-refresh the first pages
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _items.length + (_hasMore ? 1 : 0), // +1 for loader
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              // loader row at the end while we have more to fetch
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final p = _items[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${p.id}')),
              title: Text(p.name), // make sure this is a String
              subtitle: Text('ID: ${p.id}'),
              onTap: () {
                // TODO: navigate to detail if you like
              },
            );
          },
        ),
      ),
    );
  }
}
