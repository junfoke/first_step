import 'package:flutter/material.dart';
import '../models/pokemon_list_response.dart';
import '../services/poke_api_service.dart';
import 'detail_screen.dart';

class PokemonSearchDelegate extends SearchDelegate {
  final PokeApiService _apiService = PokeApiService();
  List<PokemonListItem>? _allPokemons;

  PokemonSearchDelegate();

  Future<void> _fetchAllPokemonsOnce() async {
    if (_allPokemons == null) {
      try {
        final response = await _apiService.fetchAllPokemons();
        _allPokemons = response.results;
      } catch (e) {
        debugPrint('Error fetching all pokemons for search: $e');
        _allPokemons = [];
      }
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type a Pokémon name'));
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder(
      future: _fetchAllPokemonsOnce(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _allPokemons == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_allPokemons == null || _allPokemons!.isEmpty) {
          return const Center(child: Text('Failed to load Pokémon list for search.'));
        }

        final results = _allPokemons!.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase());
        }).toList();

        if (results.isEmpty) {
          return const Center(child: Text('No Pokémon found.'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final pokemon = results[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(pokemon.imageUrl),
                backgroundColor: Colors.transparent,
              ),
              title: Text(pokemon.name.toUpperCase()),
              onTap: () {
                Navigator.pushReplacement(
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
            );
          },
        );
      },
    );
  }
}
