import 'package:flutter/material.dart';
import '../pokemon.dart';

import '../utils/formatters.dart';

class PokedexList extends StatefulWidget {
  const PokedexList({super.key});

  @override
  State<PokedexList> createState() => _PokedexListState();
}

class _PokedexListState extends State<PokedexList> {
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
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + (_hasMore ? 1 : 0),
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
            title: Text('#${p.id} ${p.name}'), // make sure this is a String
            subtitle: Text('ID: ${p.id}'),
            onTap: () {
              // TODO: navigate to detail if you like
            },
          );
        },
      ),
    );
  }
}
