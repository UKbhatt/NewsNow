import 'package:newapp/repository/newRepository.dart';
import 'package:newapp/model/NewsHeadlines.dart';
import 'package:newapp/model/NewsSource.dart';
import 'package:newapp/model/Smallnews.dart';

class Newviewmodel {
  final _rep = Newrepository();

  Future<NewsHeadlines> fetchNewsHeadlines(String source) async {
    final response = await _rep.fetchNewsHeadlines(source);

    return response;
  }

  Future<Sources> fetchNewsSources() async {
    final response = await _rep.fetchNewsSources();
    return response;
  }

  Future<Smallnews> fetchSmallNews() async {
    final response = await _rep.fetchSmallNews();
    return response;
  }

}
