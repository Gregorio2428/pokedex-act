class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Pokemon.fromListJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final segments =
        Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).toList();
    final id = int.parse(segments.last);

    return Pokemon(
      id: id,
      name: json['name'] as String,
      imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
          'sprites/pokemon/other/official-artwork/$id.png',
    );
  }

  String get displayName => name[0].toUpperCase() + name.substring(1);

  String get paddedId => '#${id.toString().padLeft(3, '0')}';
}