import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:abugida_online/utils/httpUrl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyCourses extends StatefulWidget {
  @override
  _MyCoursesState createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
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
              child: Text(
                '$Detail',
                style: GoogleFonts.fredokaOne(
                  textStyle: TextStyle(
                    color: Colors.white,
                    letterSpacing: .5,
                    fontSize: 20,
                  ),
                ),
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
        appBar: new AppBar(
          elevation: 2,
          backgroundColor: Color(0xff229546),
          shadowColor: Color(0x502196F3),
          title: Text('My Courses',
              style: TextStyle(
                  color: new Color(0xffffffff),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ),
        body: StaggeredGridView.count(
          physics: AlwaysScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(
                    0xff000000,
                    0xff229546,
                    'Amharic',
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(0xff000000, 0xff229546, 'English')),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(0xff000000, 0xff229546, 'Chemistry')),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(0xff000000, 0xff229546, 'Math')),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildrequestPopupDialog(context),
                    );
                  },
                  child: myItems2(0xff000000, 0xff229546, 'Physics')),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {},
                  child: myItems2(0xff000000, 0xff229546, 'Biology')),
            ),
          ],
          staggeredTiles: [
            StaggeredTile.extent(1, 150.0),
            StaggeredTile.extent(1, 150.0),
            StaggeredTile.extent(1, 150.0),
            StaggeredTile.extent(1, 150.0),
            StaggeredTile.extent(1, 150.0),
            StaggeredTile.extent(1, 150.0),
          ],
        ),
      ),
    );
  }

  Widget _buildrequestPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 2)),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
              child: GestureDetector(
                onTap: () {},
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xff229546),
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Align(
                          child: Text(
                            'Resources',
                            style: GoogleFonts.fredokaOne(
                              textStyle: TextStyle(
                                color: Colors.white,
                                letterSpacing: .5,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xff229546),
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Assignments',
                        style: GoogleFonts.fredokaOne(
                          textStyle: TextStyle(
                            color: Colors.white,
                            letterSpacing: .5,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
            style: TextStyle(
                color: Color(0xff229546), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
