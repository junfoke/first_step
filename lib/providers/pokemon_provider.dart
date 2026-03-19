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

  String? _selectedType;
  String? get selectedType => _selectedType;

  Future<void> fetchPokemons() async {
    if (_isLoading || (!_hasMore && _selectedType == null)) return;

    debugPrint('[Provider] Starting to fetch pokemons (offset: $_offset, type: $_selectedType)');
    _isLoading = true;
    notifyListeners();

    try {
      if (_selectedType != null) {
        // Fetch all by type
        final response = await _apiService.fetchPokemonsByType(_selectedType!);
        debugPrint('[Provider] Received ${response.results.length} pokemons of type $_selectedType');
        _pokemonList.clear(); // Reset list when filtering
        _pokemonList.addAll(response.results);
        _hasMore = false; // Type fetch returns all at once
      } else {
        // Normal paginated fetch
        final response = await _apiService.fetchPokemons(
          offset: _offset,
          limit: _limit,
        );
        debugPrint('[Provider] Received ${response.results.length} pokemons');
        _pokemonList.addAll(response.results);
        _offset += _limit;
        if (response.next == null) {
          _hasMore = false;
          debugPrint('[Provider] No more pokemons to fetch');
        }
      }
    } catch (e) {
      debugPrint('[Provider] Error fetching pokemons: $e');
      _hasMore = false; // Stop trying if there's an error
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('[Provider] Fetching finished. Total count: ${_pokemonList.length}');
    }
  }

  void applyTypeFilter(String type) {
    _selectedType = type;
    _offset = 0;
    _pokemonList.clear();
    _hasMore = true;
    fetchPokemons();
  }

  void clearFilter() {
    if (_selectedType == null) return;
    _selectedType = null;
    _offset = 0;
    _pokemonList.clear();
    _hasMore = true;
    fetchPokemons();
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
