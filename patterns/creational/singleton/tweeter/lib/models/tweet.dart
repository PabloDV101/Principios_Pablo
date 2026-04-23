class Tweet {
  final int id;
  final String tweet;

  Tweet({
    required this.id,
    required this.tweet,
  });

  /// Convert JSON to Tweet object
factory Tweet.fromJson(Map<String, dynamic> json) {
  return Tweet(
    id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
    tweet: json['tweet'] ?? '',
  );
}
  /// Convert Tweet object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tweet': tweet,
    };
  }

  @override
  String toString() => 'Tweet(id: $id, tweet: $tweet)';
}
