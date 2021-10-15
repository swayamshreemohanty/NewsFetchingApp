import 'dart:async';
import 'dart:convert';
import 'package:news_app_with_bloc_pattern/news_info.dart';
import 'package:http/http.dart' as http;

enum NewsAction {
  fetch,
  delete,
}

class NewsBloc {
  final _stateStreamController = StreamController<List<Article>>();
  StreamSink<List<Article>> get _newsSink => _stateStreamController.sink;
  Stream<List<Article>> get newsStream => _stateStreamController.stream;

  final _eventStreamController = StreamController<NewsAction>();
  StreamSink<NewsAction> get eventSink => _eventStreamController.sink;
  Stream<NewsAction> get eventStream => _eventStreamController.stream;

  NewsBloc() {
    eventStream.listen((event) async {
      if (event == NewsAction.fetch) {
        try {
          var news = await getNews();
          if (news != "Error") {
            _newsSink.add(news.articles);
          } else {
            _newsSink.addError('Something went wrong');
          }
        } on Exception catch (e) {
          _newsSink.addError('Something went wrong');
        }
      }
    });
  }

  Future<dynamic> getNews() async {
    var client = http.Client();
    dynamic newsModel;
    try {
      String apiKey =
          "https://newsapi.org/v2/everything?domains=wsj.com&apiKey=764274ea3f5d46b69a381c278b144b1b";
      var url = Uri.parse(apiKey);
      var response = await client.get(url);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);
        newsModel = NewsModel.fromJson(jsonMap);
      }
    } catch (exception) {
      return "Error";
    }
    return newsModel;
  }

  void dispose() {
    _stateStreamController.close();
    _eventStreamController.close();
  }
}
