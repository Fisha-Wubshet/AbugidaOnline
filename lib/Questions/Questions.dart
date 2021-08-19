import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:abugida_online/utils/httpUrl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Questions extends StatefulWidget {
  @override
  _QuestionsState createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AdminHome());
  }
}

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  SharedPreferences sharedPreferences;
  DateTime TimeNow = DateTime.now();
  List users = [];
  List BySerial = [];
  bool isLoading = false;
  int todoCount = 0;
  _getRequests() async {
    setState(() {});
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;

  Material myItems1(int color, int color2, String Detail, int count) {
    return Material(
      color: Color(color2),
      elevation: 14,
      shadowColor: Color(0x802196F3),
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
          topLeft: Radius.circular(10.0),
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '$Detail',
                  style: TextStyle(
                      color: new Color(color),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$count',
                    style: TextStyle(
                        color: new Color(color),
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Material myItems2(int color, int color2, String Detail) {
    return Material(
        color: Color(color2),
        elevation: 14,
        shadowColor: Color(0x802196F3),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.0),
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('$Detail',
                      style: TextStyle(
                          color: new Color(color),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshList,
      child: Scaffold(
        body: StaggeredGridView.count(
          physics: AlwaysScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(
                    0xff000000,
                    0xffB0C4DE,
                    'Assignments',
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(0xff000000, 0xff20B2AA, 'Resources')),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(0xff000000, 0xffDEB887, 'Notices')),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(0xff000000, 0xffBC8F8F, 'Questions')),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(0xff000000, 0xffBdaF8F, 'Videos')),
            ),
          ],
          staggeredTiles: [
            StaggeredTile.extent(2, 100.0),
            StaggeredTile.extent(2, 100.0),
            StaggeredTile.extent(2, 100.0),
            StaggeredTile.extent(2, 100.0),
          ],
        ),
      ),
    );
  }
}
