class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItem> results;

  PokemonListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((item) => PokemonListItem.fromJson(item))
          .toList(),
    );
  }
}

class PokemonListItem {
  final String name;
  final String url;

  PokemonListItem({required this.name, required this.url});

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'],
      url: json['url'],
    );
  }

  // Extract ID from URL (e.g., https://pokeapi.co/api/v2/pokemon/1/)
  int get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    // The last segment might be empty if there's a trailing slash, so we take the second to last if needed
    final idString = segments.lastWhere((segment) => segment.isNotEmpty);
    return int.parse(idString);
  }

  // Handy getter for low-res image for the list view
  String get imageUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }
}
