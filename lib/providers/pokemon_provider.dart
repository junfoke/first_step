import 'package:flutter/material.dart';
import '../models/pokemon_list_response.dart';
import '../models/pokemon_detail.dart';
import '../services/poke_api_service.dart';

class PokemonProvider extends ChangeNotifier {
  final PokeApiService _apiService = PokeApiService();

  final List<PokemonListItem> _pokemonList = [];
  List<PokemonListItem> get pokemonList => _pokemonList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _offset = 0;
  final int _limit = 20;

  Future<void> fetchPokemons() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    // Don't call notifyListeners here to avoid layout rebuild loops during scroll, 
    // unless we need to show a bottom loading indicator.
    // For now we will notify to show initial loading.
    if (_offset == 0) {
      notifyListeners();
    }

    try {
      final response = await _apiService.fetchPokemons(offset: _offset, limit: _limit);
      _pokemonList.addAll(response.results);
      _offset += _limit;
      if (response.next == null) {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error fetching pokemons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pre-load on startup
  void init() {
    if (_pokemonList.isEmpty) {
      fetchPokemons();
    }
  }

  // Map to hold cached pokemon details
  final Map<int, PokemonDetail> _pokemonDetails = {};
  
  Future<PokemonDetail?> getPokemonDetail(int id) async {
    if (_pokemonDetails.containsKey(id)) {
      return _pokemonDetails[id];
    }
    try {
      final detail = await _apiService.fetchPokemonDetail(id);
      _pokemonDetails[id] = detail;
      notifyListeners();
      return detail;
    } catch (e) {
      debugPrint('Error fetching pokemon detail: $e');
      return null;
    }
  }
}
