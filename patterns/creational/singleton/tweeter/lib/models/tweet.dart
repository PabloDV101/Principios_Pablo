class Tweet{
	final int id;
	final String tweet;

	Tweet({	
		required this.id,
		required this.tweet,
	});
	factory Tweet.fromJson(Map<String,dynamic> json){
	return Tweet(
		id: json['id']??'',
		tweet: json['tweet']??'',
		);
	}
	
	Map<String, dynamic> toJson(){
	return {
	'id':id,
	'tweet':tweet,
	};
	}
@override
String toString() => 'Tweet(id: $id, tweet: $tweet)';
}
