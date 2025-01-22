import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:newapp/model/NewsHeadlines.dart';
import 'package:http/http.dart';
import '../model/Smallnews.dart';
import '../model/NewsSource.dart';
import 'dart:convert';

class Newrepository {
  Future<NewsHeadlines> fetchNewsHeadlines(String source) async {
    final apiKey = dotenv.env['APIKEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    final response = await get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?sources=$source&apiKey=$apiKey'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return NewsHeadlines.fromJson(data);
    } else {
      throw Exception(
          'Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  Future<Sources> fetchNewsSources() async {
    final apiKey = dotenv.env['APIKEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    final response = await get(Uri.parse(
        'https://newsapi.org/v2/top-headlines/sources?apiKey=$apiKey'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return Sources.fromJson(data);
    } else {
      throw Exception(
          'Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  Future<Smallnews> fetchSmallNews() async {
    final apikey = dotenv.env['APIKEY'];

    if (apikey == null || apikey.isEmpty) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    final Response = await get(Uri.parse(
        'https://newsapi.org/v2/everything?q=bitcoin&apiKey=$apikey'));

    if (Response.statusCode == 200) {
      var data = jsonDecode(Response.body);
      return Smallnews.fromJson(data);
    } else {
      throw Exception(
          'Failed to fetch data. Status code: ${Response.statusCode}');
    }
  }
}
