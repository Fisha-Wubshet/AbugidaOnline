import 'package:flutter/material.dart';
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


class OnlineAssignment extends StatefulWidget {
  final exam_id;
  final exam_name;
  final started_at;
  final ends_at;
  final exam_type;

  OnlineAssignment({
    this.exam_id,
    this.exam_name,
    this.started_at,
    this.ends_at,
    this.exam_type
  });

  @override
  _OnlineAssignmentState createState() => _OnlineAssignmentState();
}

class _OnlineAssignmentState extends State<OnlineAssignment> {
  var picker = '';
  List allQuestion =[];
  List QuestionsId =[];
  int Question_no =0;
  var take_id;
  List correctAnswers = [];
  bool isLoading = false;
  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;
  var myDateTimeFromInternet;
  bool examtimeloader = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetchAllQuestion();
    this.takeExams();
    examStart();


  }
  Timer _timer;
  double _start;
  var duration;
  var ttt=5.0;

  var score;

  FinishExam(take_id) async {
    setState(() {
      isLoading = true;
      print( "question_id: " "$QuestionsId, "
          "answer_id: " "$correctAnswers, "
          "take_id: " "${take_id} }");
    });
    int timeout=20;
    try
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url = Uri.parse("$httpUrl/api/finishMobileExam");
      var response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "question_id": json.encode(QuestionsId),
        "answer_id": json.encode(correctAnswers),
        "take_id": "$take_id"
      }).timeout(Duration(seconds: timeout));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var items = response.body;
        score=items;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => _buildScorePopupDialog(context, score),
        );
        print("${response.statusCode}");
        print("${response.body}");

        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Successfully Ordered",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        print("${response.statusCode}");
        print("${response.body}");
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Order failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      }
    }
    on TimeoutException catch (e) {
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
  examStart() async {

    if(widget.exam_type!='Assignment') {
      examtimeloader=true;
      myDateTimeFromInternet = await dateTimeFromInternet();
      _start = (widget.ends_at.millisecondsSinceEpoch -
          myDateTimeFromInternet.millisecondsSinceEpoch) /
          1;
      duration = _start;

      print('========================================');
      print(duration);

    }
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day, from.hour,from.minute, from.second);
    to = DateTime(to.year, to.month, to.day, from.hour,from.minute, from.second);
    return (to.difference(from).inDays);
  }
  takeExams() async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url =
      Uri.parse("$httpUrl/api/takeExams/${widget.exam_id}");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 201) {
        var items = json.decode(response.body);
        setState(() {
          take_id = items['id'];
          print('aaaaaaaaaaaaaaaaaaaaaaaaaa');
          print(take_id);
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
          allQuestion = [];
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
  fetchAllQuestion() async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url =
      Uri.parse("$httpUrl/api/getMyExam/${widget.exam_id}");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);

      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          allQuestion = items;
          for(int i=0; i<allQuestion.length; i++){
            correctAnswers.add('');
            QuestionsId.add(allQuestion[i]['question_id']);
          }
          picker = correctAnswers[0];
          isLoading = false;

          print(allQuestion.length);
          print(correctAnswers);
        });

      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(
            msg: "Your Account is Locked",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        setState(() {
          allQuestion = [];
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

  @override
  Widget build(BuildContext context) {
    if ( isLoading && examtimeloader) {
      return Material(
          child: SpinKitDoubleBounce(
            color: Color(0xff229546),
            size: 71,
          ));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.exam_name}'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Icon(
                Icons.lightbulb_outline,
                size: 100,
                color: Colors.red,
              ),
              if(allQuestion.length!=0)
                Text(
                  'Q${Question_no+1}. ${allQuestion[Question_no]['question']} (${allQuestion[Question_no]['score']} Marks)',
                  style: TextStyle(fontSize: 24),
                ),
              for(var i = 0; i < allQuestion[Question_no]['answers'].length; i++)
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                          value: '${allQuestion[Question_no]['answers'][i]['id']}',
                          groupValue: picker,
                          onChanged: (val) {
                            picker = val;
                            setState(() {
                              print(picker);
                              correctAnswers[Question_no]=val;
                              print(correctAnswers);
                            });
                          }),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.7,
                        child: Text(
                          allQuestion[Question_no]['answers'][i]['content'],
                          style: TextStyle(fontSize: 24),
                        ),
                      )
                    ],
                  ),
                ),
              if(Question_no>0)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      InkWell(
                        onTap: () {
                          setState(() {
                            Question_no= Question_no - 1;
                            print(correctAnswers);
                            picker = correctAnswers[Question_no];
                          });
                        },
                        child: Icon(
                          Icons.arrow_back_ios_sharp,
                          size: 60,
                          color: Colors.red,
                        ),
                      ),
                      if(Question_no!=allQuestion.length-1)
                        InkWell(
                          onTap: () {
                            setState(() {
                              Question_no=Question_no + 1;
                              picker= correctAnswers[Question_no];
                              print(correctAnswers);
                            });

                          },
                          child: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 60,
                            color: Colors.red,
                          ),
                        ),
                      if(Question_no==allQuestion.length-1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            FinishExam(take_id);
                          });

                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 50,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Color(0xff229546),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Align(
                                  child: Text(
                                    'Finish',  style: GoogleFonts.fredokaOne(
                                    textStyle: TextStyle(color: Colors.white,letterSpacing: .5, fontSize: 17,),),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if(Question_no==0)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if(Question_no!=allQuestion.length-1)
                        InkWell(
                          onTap: () {
                            //-------------------------------------------------


                            setState(() {
                              Question_no=Question_no + 1;
                              print(correctAnswers);
                              picker = correctAnswers[Question_no];

                            });

                          },
                          child: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 60,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              if(allQuestion.length==1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      FinishExam(take_id);
                    });

                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Color(0xff229546),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Align(
                            child: Text(
                              'Finish',  style: GoogleFonts.fredokaOne(
                              textStyle: TextStyle(color: Colors.white,letterSpacing: .5, fontSize: 17,),),),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
  Widget _buildScorePopupDialog(BuildContext context, score) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context,true);
        Navigator.pop(context,true);
      },
      child: new AlertDialog(

        backgroundColor: Color(0xff566d60),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
              padding:
              const EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: Text('score:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Colors.white)),
                  ),
                  new Text('$score',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white)),
                ],
              )),
        ),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.pop(context,true);
              Navigator.pop(context,true);
            },
            child: const Text('Ok',
                style: TextStyle(
                    color: Color(0xffffffff), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}