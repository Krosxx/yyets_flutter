import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/app/Stroage.dart';
import 'package:flutter_yyets/ui/load/LoadingStatus.dart';

class SearchPageDelegate extends SearchDelegate<Map> {
  @override
  Widget buildSuggestions(BuildContext context) {
    return _SuggestionPage(query);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = "";
            }
          })
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      query = "";
      return Container();
    } else {
      return _ResultPage(query);
    }
  }
}

class _SuggestionPage extends StatefulWidget {
  final String query;

  _SuggestionPage(this.query);

  @override
  State createState() => _SuggestionState();
}

class _SuggestionState extends State<_SuggestionPage> {
  List<String> suggestions = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (c, i) {
          return ListTile(
            title: Text(suggestions[i]),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    querySuggest(widget.query).then((value) {
      setState(() {
        suggestions = value;
      });
    });
  }
}

class _ResultPage extends StatefulWidget {

  final String query;

  _ResultPage(this.query);

  @override
  State createState() => _ResultPageState();

}

class _ResultPageState extends State<_ResultPage> {

  List results = [];

  LoadingStatus _status = LoadingStatus.LOADING;

  @override
  void initState() {
    Api.search(widget.query).then((value) =>
    {
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
        itemBuilder: (c, i) {
      return ListTile(
        title: Text(results[i]),
      );
    });
  }
}