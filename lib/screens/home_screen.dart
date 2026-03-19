import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import 'detail_screen.dart';
import 'search_delegate.dart';
import 'favorites_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đảm bảo fetch được gọi khi provider đã sẵn sàng
    final provider = context.read<PokemonProvider>();
    if (provider.pokemonList.isEmpty && !provider.isLoading) {
      provider.fetchPokemons();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PokemonProvider>().fetchPokemons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: PokemonSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showTypeFilterBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          debugPrint('[UI] HomeScreen build called. List count: ${provider.pokemonList.length}, isLoading: ${provider.isLoading}');
          
          if (provider.pokemonList.isEmpty && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.pokemonList.isEmpty) {
            debugPrint('[UI] List is empty - showing "No Pokémon found."');
            return const Center(child: Text('No Pokémon found.'));
          }

          debugPrint('[UI] Rendering GridView with ${provider.pokemonList.length} items');
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: provider.pokemonList.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom when fetching more
              if (index == provider.pokemonList.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final pokemon = provider.pokemonList[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    debugPrint('[UI] Tapped on pokemon: ${pokemon.name} (ID: ${pokemon.id})');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(
                          pokemonId: pokemon.id,
                          pokemonName: pokemon.name,
                          imageUrl: pokemon.imageUrl,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          height: 100,
                          width: 100,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            debugPrint('[UI] Error loading image for ${pokemon.name}: $error');
                            return const Icon(Icons.error);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pokemon.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTypeFilterBottomSheet(BuildContext context) {
    // Standard Pokemon types
    final List<String> types = [
      'normal', 'fire', 'water', 'grass', 'electric', 'ice', 'fighting',
      'poison', 'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost',
      'dark', 'dragon', 'steel', 'fairy'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        return Consumer<PokemonProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by Type',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (provider.selectedType != null)
                        TextButton(
                          onPressed: () {
                            provider.clearFilter();
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Clear Filter'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: types.length,
                      itemBuilder: (context, index) {
                        final type = types[index];
                        final isSelected = type == provider.selectedType;
                        
                        return InkWell(
                          onTap: () {
                            provider.applyTypeFilter(type);
                            Navigator.pop(sheetContext);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.red : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.red : Colors.grey[300]!,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
