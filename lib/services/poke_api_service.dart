import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/pokemon_list_response.dart';
import '../models/pokemon_detail.dart';

class PokeApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<PokemonListResponse> fetchPokemons({
    int offset = 0,
    int limit = 20,
  }) async {
    final url = '$baseUrl/pokemon?offset=$offset&limit=$limit';
    debugPrint('[API] Fetching pokemons: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('[API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PokemonListResponse.fromJson(data);
      } else {
        debugPrint('[API] Error: Status ${response.statusCode}');
        throw Exception('Failed to load pokemons');
      }
    } catch (e) {
      debugPrint('[API] Exception: $e');
      rethrow;
    }
  }

  Future<PokemonListResponse> fetchPokemonsByType(String type) async {
    final url = '$baseUrl/type/$type';
    debugPrint('[API] Fetching pokemons by type: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pokemonArray = data['pokemon'] as List;
        
        // The type endpoint returns data in { pokemon: { name, url } } format.
        // We need to map it back to PokemonListItem
        final results = pokemonArray.map((p) {
          final pokemonData = p['pokemon'];
          return PokemonListItem.fromJson(pokemonData);
        }).toList();

        // Note: filtering by type doesn't have next/previous pagination in PokeAPI
        return PokemonListResponse(count: results.length, results: results, next: null, previous: null);
      } else {
        debugPrint('[API] Error type $type: ${response.statusCode}');
        throw Exception('Failed to load pokemons by type');
      }
    } catch (e) {
      debugPrint('[API] Exception type $type: $e');
      rethrow;
    }
  }

  Future<PokemonListResponse> fetchAllPokemons() async {
    debugPrint('[API] Fetching all pokemons...');
    final response = await http.get(Uri.parse('$baseUrl/pokemon?limit=10000'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PokemonListResponse.fromJson(data);
    } else {
      debugPrint('[API] Error fetching all: ${response.statusCode}');
      throw Exception('Failed to load all pokemons');
    }
  }

  Future<PokemonDetail> fetchPokemonDetail(int id) async {
    debugPrint('[API] Fetching detail for ID: $id');
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PokemonDetail.fromJson(data);
    } else {
      debugPrint('[API] Error detail ID $id: ${response.statusCode}');
      throw Exception('Failed to load pokemon details');
    }
  }
}
