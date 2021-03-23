import 'package:flutter/material.dart';

class SearchFiltersScreen extends StatefulWidget {
  @override
  _SearchFiltersScreenState createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filter'),),
      body: Container(
        child: Column(),
      ),
    );
  }
}