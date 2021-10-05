import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abugida_online/main.dart';
import 'package:abugida_online/resources/Resources.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

//================================================================================

class NoticeList extends StatefulWidget {
  @override
  _NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  _getRequests() async {
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(loginVerified: true)),
              (Route<dynamic> route) => false);
    });
  }

  List Notice = [];
  List BalanceArray = [];
  bool isLoading = false;
  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;
  double Balance = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetchCourses();
  }

  fetchCourses() async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url = Uri.parse("$httpUrl/api/getLatestNotices");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          Notice = items;
          isLoading = false;
        });
      } else {
        Notice = [];
        isLoading = false;
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
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //text
                  Text(
                    'Notices',
                    textAlign: TextAlign.center,
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

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: refreshList,
        child: Scaffold(
          body: socketException || timeoutException
              ? NoConnectionBody()
              : getBody(),
        ));
  }

  Widget getBody() {
    if (Notice.contains(null) || Notice.length < 0 || isLoading) {
      return Material(
          child: SpinKitThreeBounce(
            color: Color(0xff229546),
            size: 30,
          ));
    }
    return SingleChildScrollView(
        child: Column(

          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 8),
              child: StaggeredGridView.count(
                shrinkWrap: true,
                crossAxisCount: 1,
                physics: ScrollPhysics(),
                children: <Widget>[
                  myItems1(0xff000000),
                ],
                staggeredTiles: [
                  StaggeredTile.extent(1, 30.0),
                ],
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: Notice.length,
                itemBuilder: (context, index) {
                  return getCard(Notice[index]);
                }),
          ],
        ),

    );
  }
  Widget getCard(item) {
    var notice_title = item['notice_title'];
    var f_name = item['f_name'];
    var type = item['type'];
    var posted  = item['posted'];
    var notice_body = item['notice_body'];
    var dateTimeString = '${(item['created_at'])}';
    final dateTime = DateTime.parse(dateTimeString).toLocal();
    final format = DateFormat('yyyy-MM-dd h:mm a');
    final clockString = format.format(dateTime);

    //=====================================

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => _buildPopupDialog(context, type,  notice_body),
        );
      },
      child: Card(
        elevation: 3,
        shadowColor: Color(0x502196F3),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: Icon(Icons.message, color: Color(0xff229546)),
            title: Row(
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 130,
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: notice_title,
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
                      width: MediaQuery.of(context).size.width - 130,
                      child: Text.rich(
                        TextSpan(

                          children: <TextSpan>[
                            TextSpan(
                                text: "$type: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                )),
                            TextSpan(
                                text: f_name,
                                style: TextStyle(
                                  color: Colors.grey,

                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$posted',
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget NoConnectionBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/animation.png'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                icon: Icon(
                  Icons.refresh_sharp,
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
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              margin: EdgeInsets.only(top: 15.0),
              child: RaisedButton(
                onPressed: () {},
                elevation: 0.0,
                color: Color(0xff82C042),
                child: Text("Download", style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPopupDialog(BuildContext context,type, notice_body) {
    return new AlertDialog(


      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16,),
                  child: Icon(Icons.format_quote, color: Colors.lightGreen, size: 40,),
                ),

                Center(
                  child: SingleChildScrollView(
                    child: Html(
                      data: """
                $notice_body
                """,
                      padding: EdgeInsets.all(8.0),
                      onLinkTap: (url) {
                        print("Opening $url...");
                      },
                      customRender: (node, children) {
                        if (node is dom.Element) {
                          switch (node.localName) {
                            case "custom_tag": // using this, you can handle custom tags in your HTML
                              return Column(children: children);
                          }
                        }
                      },
                    ),
                  ),
                )
              ],
            )
        ),
      ),





      actions: <Widget>[

        new FlatButton(
          onPressed: () {


            Navigator.of(context).pop();
          },
          child: const Text('close' , style: TextStyle(color: Color(0xff000000), fontWeight: FontWeight.bold)),
        ),

      ],
    );
  }
}
