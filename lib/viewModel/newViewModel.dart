import 'package:newapp/repository/newRepository.dart';
import 'package:newapp/model/NewsHeadlines.dart';

class Newviewmodel{

  final _rep = Newrepository();

  Future<NewsHeadlines> fetchNewsHeadlines()async{

    final response = await _rep.fetchNewsHeadlines();
    return response;
  }

}