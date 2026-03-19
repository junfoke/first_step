import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/pokemon_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/pokemon_detail.dart';

class DetailScreen extends StatelessWidget {
  final int pokemonId;
  final String pokemonName;
  final String imageUrl;

  const DetailScreen({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemonName.toUpperCase()),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, provider, child) {
              final isFavorite = provider.isFavorite(pokemonId);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.pinkAccent : Colors.white,
                ),
                onPressed: () {
                  provider.toggleFavorite(pokemonId);
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<PokemonDetail?>(
        future: context.read<PokemonProvider>().getPokemonDetail(pokemonId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingView();
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Failed to load Pokémon details.'));
          }

          final detail = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'pokemon-$pokemonId',
                  child: CachedNetworkImage(
                    imageUrl: detail.imageUrl.isNotEmpty
                        ? detail.imageUrl
                        : imageUrl,
                    height: 250,
                    width: 250,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  detail.name.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: detail.types
                      .map(
                        (type) => Chip(
                          label: Text(
                            type.toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getTypeColor(type),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Height', '${detail.height / 10} m'),
                        _buildStatColumn('Weight', '${detail.weight / 10} kg'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
          child: Hero(
            tag: 'pokemon-$pokemonId',
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 250,
              width: 250,
              color: Colors.black26,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return Colors.brown[400]!;
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.amber;
      case 'ice':
        return Colors.cyanAccent[400]!;
      case 'fighting':
        return Colors.orange;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.orange[300]!;
      case 'flying':
        return Colors.indigo[200]!;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen[500]!;
      case 'rock':
        return Colors.grey;
      case 'ghost':
        return Colors.indigo[400]!;
      case 'dark':
        return Colors.brown[900]!;
      case 'dragon':
        return Colors.deepPurple[400]!;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pinkAccent[100]!;
      default:
        return Colors.grey;
    }
  }
}
