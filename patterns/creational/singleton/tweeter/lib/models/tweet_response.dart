import 'tweet.dart';

class TweetResponse{
	final List<Tweet> content;
	TweetResponse({
	required this.content,
});

factory TweetResponse.fromJson(Map<String,dynamic> json){
	final contentList = json['content'] as List<dynamic>? ?? [];
	return TweetResponse(
		content:contentList
		.map((tweet) => Tweet.fromJson(tweet as Map<String, dynamic>))
		.toList(),
	);
}
@override
String toString() =>
	'TweetResponse(content: ${content.length},totalElements)';
	
}
