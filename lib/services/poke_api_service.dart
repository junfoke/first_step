import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_list_response.dart';
import '../models/pokemon_detail.dart';

class PokeApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<PokemonListResponse> fetchPokemons({
    int offset = 0,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon?offset=$offset&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PokemonListResponse.fromJson(data);
    } else {
      throw Exception('Failed to load pokemons');
    }
  }

  Future<PokemonDetail> fetchPokemonDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PokemonDetail.fromJson(data);
    } else {
      throw Exception('Failed to load pokemon details');
    }
  }
}
