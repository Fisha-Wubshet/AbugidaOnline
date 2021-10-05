import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:abugida_online/MyCourses.dart';
import 'package:abugida_online/Notice/NoticeList.dart';
import 'package:abugida_online/Quiz/CourseExams.dart';
import 'package:abugida_online/Quiz/QuizChoice.dart';
import 'package:abugida_online/Videos/Videos.dart';
import 'package:abugida_online/assignment/CourseAssignment.dart';
import 'package:abugida_online/download/downloadFolder.dart';
import 'package:abugida_online/resources/CourseResources.dart';
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

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  SharedPreferences sharedPreferences;
  DateTime TimeNow = DateTime.now();
  List DashDataCount = [];
  List BySerial = [];
  bool isLoading = false;
  int resourceCount = 0;
  int downloadCount = 0;
  int assignmentCount = 0;
  int submissionCount = 0;
  int noticeCount = 0;
  _getRequests() async {
    setState(() {});
  }

  DashData() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = Uri.parse("$httpUrl/api/getStudDashData");
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var items = json.decode(response.body);
      DashDataCount.add(items);

      setState(() {
        resourceCount = DashDataCount[0]['resourceCount'];
        downloadCount = DashDataCount[0]['downloadCount'];
        assignmentCount = DashDataCount[0]['assignmentCount'];
        submissionCount = DashDataCount[0]['submissionCount'];
        noticeCount = DashDataCount[0]['noticeCount'];
        print(DashDataCount);
        print(DashDataCount[0]['resourceCount']);
        print(DashDataCount[0]['downloadCount']);

        isLoading = false;
      });
    } else {
      print(response.body);
      DashDataCount = [];
      isLoading = false;
    }
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  void initState() {
    DashData();
    super.initState();
  }

  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;

  Material myItems1(
      int color, int color2, String Detail, Iconest, total, count, item) {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Iconest,
                          color: Color(0xff229546),
                        ),
                        Text(
                          '  $Detail',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Divider(color: Color(0xff229546)),
                  ),
                  Text(' $count/$total $item',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      )),
                ],
              ),
            ),
          ),
        ));
  }

  Material myItems2(int color, int color2, String Detail, Iconest) {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Iconest, color: Color(0xff229546)),
                        Text(
                          '  $Detail',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Divider(color: Color(0xff229546)),
                  )
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
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new CourseResources()));
                  },
                  child: myItems1(
                      0xff000000,
                      0xffffffff,
                      'Resources',
                      Icons.menu_book,
                      resourceCount,
                      downloadCount,
                      'Downloaded')),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new CourseAssignment()));
                  },
                  child: myItems1(
                      0xff000000,
                      0xffffffff,
                      'Assignment',
                      Icons.library_books,
                      assignmentCount,
                      submissionCount,
                      'Submited')),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CourseExams()));
                  },
                  child: myItems2(
                      0xff000000, 0xffffffff, 'Exam', Icons.edit_road_sharp)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new NoticeList()));
                  },
                  child: myItems2(
                      0xff000000, 0xffffffff, 'Notice', Icons.message)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new YoutubePlayerDemoApp()));
                  },
                  child: myItems2(0xff000000, 0xffffffff, 'Videos',
                      Icons.video_collection_rounded)),
            ),
          ],
          staggeredTiles: [
            StaggeredTile.extent(2, 120.0),
            StaggeredTile.extent(2, 120.0),
            StaggeredTile.extent(2, 120.0),
            StaggeredTile.extent(2, 120.0),
            StaggeredTile.extent(2, 120.0),
          ],
        ),
      ),
    );
  }
}
