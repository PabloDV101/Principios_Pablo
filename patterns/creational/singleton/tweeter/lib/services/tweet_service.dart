import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tweeter/models/tweet.dart';
import 'package:tweeter/models/tweet_response.dart';


class TweetService {
  static final TweetService _instance = TweetService._internal();

  final String baseUrl = 'https://localhost:8080/api';
  late http.Client _httpClient;

  TweetService._internal() {
    _httpClient = http.Client();
  }

  factory TweetService() {
    return _instance;
  }
  static TweetService get instance => _instance;

  Future<List<Tweet>> fetchTweets() async {
    try{
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/tweets'));

    if (response.statusCode == 200) {
      
      final jsonData= jsonDecode(response.body) as Map<String, dynamic>;
      final tweetResponse = TweetResponse.fromJson(jsonData);
      return tweetResponse.content;
    } else {
      throw Exception('Failed to load tweets. status code: ${response.statusCode}');
    }
    }catch(e){
    throw Exception('Error fetching tweets: $e');
  }
  }
  void dispose() {
    _httpClient.close();
  }

}