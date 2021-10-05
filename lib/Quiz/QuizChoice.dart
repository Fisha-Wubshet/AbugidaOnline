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


class QuizChoice extends StatefulWidget {
  final exam_id;
  final exam_name;
  final started_at;
  final ends_at;
  final exam_type;

  QuizChoice({
    this.exam_id,
    this.exam_name,
    this.started_at,
    this.ends_at,
    this.exam_type
  });

  @override
  _QuizChoiceState createState() => _QuizChoiceState();
}

class _QuizChoiceState extends State<QuizChoice> {
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
  bool examtimeloader = true;
  bool timeloding = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetchAllQuestion();
    this.takeExams();
    examStart();
    seconds = 0;
    minutes = 0;
    hours = 0;

  }
  Timer _timer;
  double _start;
  var duration;
  var ttt=5.0;
  double hours;
  double minutes;
  double seconds;
  var score;

  FinishExam(take_id, type) async {
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
        if(type=='finished')
        {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                _buildScorePopupDialog(context, score),
          );
        }
        if(type=='TimeOut')
        {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                _buildScoreTimeoutPopupDialog(context, score),
          );
        }
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

    setState(() {
      examtimeloader=true;
    });
    myDateTimeFromInternet = await dateTimeFromInternet();
    setState(() {
      myDateTimeFromInternet= myDateTimeFromInternet;
    });
    _start = (widget.ends_at.millisecondsSinceEpoch -
        myDateTimeFromInternet.millisecondsSinceEpoch) /
        1;
    duration = _start;

    print('========================================');
    print(duration);

    startTimer();


}
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (duration < 0.0) {
          if (mounted)
            {
            setState(() {
              seconds = 0.0;
              minutes = 0;
              hours = 0;
              timer.cancel();
              FinishExam(take_id, 'TimeOut');
            }
          );}
        } else {
          if (mounted)
          {
            setState(() {
              duration = duration - 1000;
              seconds = (duration / 1000) % 60;
              minutes = (duration / (1000 * 60)) % 60;
              hours = (duration / (1000 * 60 * 60)) % 24;
              setState(() {
                timeloding = true;
              });
            });
          }
        }
      },
    );
    setState(() {
      examtimeloader = false;
    });
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
            correctAnswers.add(null);
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
    if ( isLoading || examtimeloader) {
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
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if(timeloding)
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 16),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Color(0x45229546)),
                        left: BorderSide(width: 1.0, color: Color(0x45229546)),
                        right: BorderSide(width: 1.0, color: Color(0x45229546)),
                        bottom: BorderSide(width: 1.0, color: Color(0x45229546)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 50,
                            color: Color(0xff229546),
                          ),
                          Text(
                            '${hours.toInt()} : ${minutes.toInt()} : ${seconds.toInt()}',
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: .5,
                                  fontSize: 20,
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if(allQuestion.length!=0)
                Text(
                  'Q${Question_no+1}. ${allQuestion[Question_no]['question']} (${allQuestion[Question_no]['score']} Marks)',
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .5,
                        fontSize: 20,
                      ),
                    ),
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
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  letterSpacing: .5,
                                  fontSize: 20,
                                ),
                              ),
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
                          color: Color(0xff229546),
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
                          color: Color(0xff229546),
                        ),
                      ),
                      if(Question_no==allQuestion.length-1)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              FinishExam(take_id, 'finished');
                            });

                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(

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
                            color: Color(0xff229546),
                          ),
                        ),
                    ],
                  ),
                ),
                if(allQuestion.length==1)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        FinishExam(take_id, 'finished');
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
        ));
  }
  Widget _buildScorePopupDialog(BuildContext context, score) {
    return WillPopScope(
      onWillPop: () async  {
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

  Widget _buildScoreTimeoutPopupDialog(BuildContext context, score) {
    return WillPopScope(
      onWillPop: ()  {
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
                    child: Text('TimeOut:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Colors.white)),
                  ),
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