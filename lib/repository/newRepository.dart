import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:newapp/model/NewsHeadlines.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Newrepository {
  Future<NewsHeadlines> fetchNewsHeadlines() async {
    final apiKey = dotenv.env['APIKEY'];
    
        if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    final response = await get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=$apiKey'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return NewsHeadlines.fromJson(data);
    } else {
      throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }
}

