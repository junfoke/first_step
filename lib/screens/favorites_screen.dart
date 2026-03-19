import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'detail_screen.dart';
import '../services/poke_api_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Pokémon')),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.favoriteIds.isEmpty) {
            return const Center(child: Text('No favorite Pokémon yet.'));
          }

          return ListView.builder(
            itemCount: favoritesProvider.favoriteIds.length,
            itemBuilder: (context, index) {
              final id = favoritesProvider.favoriteIds[index];
              return _FavoriteListItem(pokemonId: id);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteListItem extends StatelessWidget {
  final int pokemonId;

  const _FavoriteListItem({required this.pokemonId});

  @override
  Widget build(BuildContext context) {
    final apiService = PokeApiService();

    return FutureBuilder(
      future: apiService.fetchPokemonDetail(pokemonId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Loading...'),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final detail = snapshot.data!;
        return ListTile(
          leading: Hero(
            tag: 'fav-${detail.id}',
            child: CachedNetworkImage(
              imageUrl: detail.imageUrl,
              width: 50,
              height: 50,
            ),
          ),
          title: Text(
            detail.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.pink),
            onPressed: () {
              context.read<FavoritesProvider>().toggleFavorite(detail.id);
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(
                  pokemonId: detail.id,
                  pokemonName: detail.name,
                  imageUrl: detail.imageUrl,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
