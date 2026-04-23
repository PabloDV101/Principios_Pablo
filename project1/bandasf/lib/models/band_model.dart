class Band {
  final int? id;
  final String name;
  final String genre;
  final String imageUrl;

  Band({this.id, required this.name, required this.genre, required this.imageUrl});

  factory Band.fromJson(Map<String, dynamic> json) {
    return Band(
      id: json['id'],
      name: json['name'],
      genre: json['genre'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}