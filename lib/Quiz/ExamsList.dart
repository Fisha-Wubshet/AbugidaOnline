
import 'package:abugida_online/Quiz/QuizChoice.dart';
import 'package:abugida_online/pdftest.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:ms_datetime_extensions/ms_datetime_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamsList extends StatefulWidget {
  final course_id;
  final course_name;

  ExamsList({
    this.course_id,
    this.course_name,
  });

  @override
  _ExamsListState createState() => _ExamsListState();
}

class _ExamsListState extends State<ExamsList> {
  List users = [];
  bool isLoading = false;
  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;
  final format = DateFormat('yyyy-MM-dd h:mm:ss a');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetchUser();
  }
  _getRequests() async {
    setState(() {
      isLoading = true;

      refreshList();
    });
  }
  Material myItems1(int color) {
    return Material(
      color: Color(0xff229546),
      elevation: 14,
      shadowColor: Color(0x502196F3),
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
          topLeft: Radius.circular(10.0),
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //text
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      '${widget.course_name} Exams',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredokaOne(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xffffffff),
                          letterSpacing: 2,
                          fontSize: 18,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 5.0,
                              color: Color(0x48000000),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )

                  //balance
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  fetchUser() async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url =
      Uri.parse("$httpUrl/api/showCourseExams/${widget.course_id}");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          users = items;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(
            msg: "Your Account is Locked",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        setState(() {
          users = [];
          isLoading = false;
        });
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      setState(() {
        isLoading = false;
        timeoutException = true;
      });
      Fluttertoast.showToast(
          msg: "connection timeout, try again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } on SocketException catch (e) {
      print('Socket Error: $e');
      setState(() {
        isLoading = false;

        socketException = true;
      });
      Fluttertoast.showToast(
          msg: "no connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } on Error catch (e) {
      print('$e');
      setState(() {
        isLoading = false;
        catchException = true;
      });
      Fluttertoast.showToast(
          msg: "error occurred while loading",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    }
  }

  Future<Null> refreshList() async {
    setState(() {
      fetchUser();
    });
  }
 time() async {
   var mDateTimeFromInternet = await dateTimeFromInternet();
   print(mDateTimeFromInternet);
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(onRefresh: refreshList, child: getBody()),
    );
  }

  Widget getBody() {
    if (users.contains(null) || users.length < 0 || isLoading) {
      return Center(
          child: const SpinKitDoubleBounce(size: 71.0, color: Color(0xff229546)));
    }
    if (socketException || timeoutException) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/animation.png'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: Icon(
                        Icons.sync,
                        color: Colors.orange,
                        size: 50,
                      ),
                      onPressed: () {
                        setState(() {
                          socketException = false;
                          timeoutException = false;
                        });
                        refreshList();
                      }),
                )
              ],
            ),
          ));
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, left: 8, right: 8),
            child: StaggeredGridView.count(
              shrinkWrap: true,
              crossAxisCount: 1,
              physics: ScrollPhysics(),
              children: <Widget>[
                myItems1(0xff000000),
              ],
              staggeredTiles: [
                StaggeredTile.fit(1),
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return getCard(users[index]);
              }),
        ],
      ),
    );
  }

  Widget getCard(item) {
    var name = item['exam']['as_title'];
    var status =item["status"];
    var takenStatus=item["taken"];
    //==================================
    var dateTimeString = '${(item['exam']['starts_at'])}';
    final dateTime = DateTime.parse(dateTimeString).toLocal();
    final format = DateFormat('yyyy-MM-dd h:mm:ss a');
    final clockString = format.format(dateTime);
    final Startformat =DateTime.parse(item['exam']['starts_at']);
    final Closesformat =DateTime.parse(item['exam']['ends_at']);
    //=====================================

    return InkWell(
      onTap: () {
        time();
        showDialog(
          context: context,
          builder: (BuildContext context ) => _buildrequestPopupDialog(context,item['exam']['id'],  item['exam']['as_title'], item['exam']['value'],Startformat, Closesformat, status, takenStatus, item["score"]),
        );

      },
      child: Card(
        elevation: 5,
        shadowColor: Color(0x502196F3),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: Icon(Icons.menu_book, color: Color(0xff229546)),
            title: Row(
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                          width: MediaQuery.of(context).size.width*0.5,
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                              ],
                            ),
                          ),
                        ),


                    SizedBox(
                      height: 5,
                    ),

                    Text(
                      'posted: $clockString',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          if(takenStatus=='Taken')
                          TextSpan(
                              text: 'completed (${item["score"]})',
                              style: TextStyle(color: Color(0xff229546), fontWeight: FontWeight.bold)),
                          if(takenStatus!='Taken' && status=="Closed")
                          TextSpan(
                              text: 'Exam Missed',
                              style: TextStyle(color: Color(0xff229546), fontWeight: FontWeight.bold)),
                          if(takenStatus!='Taken' && status=="Not Started")
                            TextSpan(
                                text: 'Not Started',
                                style: TextStyle(color: Color(0xff229546), fontWeight: FontWeight.bold)),
                          if(takenStatus!='Taken' && status=="Open")
                            TextSpan(
                                text: 'Started',
                                style: TextStyle(color: Color(0xff229546), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildrequestPopupDialog(BuildContext context,Exam_id, title, value, starts, closes, status, takenStatus, score ) {
    return new AlertDialog(
      title: const Text('', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 2)),

      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Exam Title: $title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Value: $value',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Exam Status: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),

                          if(takenStatus=='Taken')
                            TextSpan(
                                text: ' completed ($score})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                          if(takenStatus!='Taken' && status=="Closed")
                            TextSpan(
                                text: ' Exam Missed',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                          if(takenStatus!='Taken' && status=="Not Started")
                            TextSpan(
                                text: ' Not Started',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),

                  ],
                ),
              ),
            ),

            SizedBox(
              height: 5,
            ),
            SizedBox(
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Exam Starts: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    TextSpan(
                        text: ' ${format.format(starts)} ',
                        style: TextStyle(
                          backgroundColor: Colors.green,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Exam Closes: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    TextSpan(
                        text: ' ${format.format(closes)} ',
                        style: TextStyle(
                          backgroundColor: Colors.red,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ))
                  ],
                ),
              ),
            ),

            if(takenStatus=='Taken')
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(

                    decoration: BoxDecoration(
                      color: Color(0x8f229546),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                         ' score: $score',
                          style: GoogleFonts.fredokaOne(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xffffffff),
                              letterSpacing: 2,
                              fontSize: 17,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                  color: Color(0x48000000),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            if(takenStatus!='Taken' && status=="Closed")
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(

                    decoration: BoxDecoration(
                      color: Color(0x8f229546),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          ' Exam Missed!',
                          style: GoogleFonts.fredokaOne(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xffffffff),
                              letterSpacing: 2,
                              fontSize: 17,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                  color: Color(0x48000000),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            if(takenStatus!='Taken' && status!="Closed" && status!="Not Started")
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuizChoice(
                              exam_id: Exam_id,
                              exam_name: title,
                              started_at:starts,
                              ends_at:closes
                          ))).then((val) => val ? _getRequests() : null);
                },

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
                            'Start',  style: GoogleFonts.fredokaOne(
                            textStyle: TextStyle(color: Colors.white,letterSpacing: .5, fontSize: 20,),),),
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
          child: const Text('Close', style: TextStyle(color: Color(0xff229546), fontWeight: FontWeight.bold),),
        ),

      ],
    );
  }

}
