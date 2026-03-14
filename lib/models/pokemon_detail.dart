class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final String imageUrl;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.imageUrl,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final typesList = json['types'] as List;
    final types = typesList.map((t) => t['type']['name'] as String).toList();

    // Use official artwork if available, otherwise fallback to default sprite
    final sprites = json['sprites'];
    final otherSprites = sprites['other'];
    final officialArtwork = otherSprites?['official-artwork']?['front_default'];
    final defaultSprite = sprites['front_default'];
    
    final imageUrl = officialArtwork ?? defaultSprite ?? '';

    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      types: types,
      imageUrl: imageUrl,
    );
  }
}
