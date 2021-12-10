
import 'dart:async';

import 'dart:io';
import 'dart:math';

import 'package:abugida_online/utils/ObscuringTextEditingController.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:async/async.dart';

import '../main.dart';

import 'package:path/path.dart' ;


class Register extends StatefulWidget {

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final TextEditingController f_nameController = new TextEditingController();
  final TextEditingController l_nameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController passwordController = new ObscuringTextEditingController();
  final TextEditingController ConfirmpasswordController =  new ObscuringTextEditingController();

  int _counter = 0;
  File _image;
  File file;
  var filepath;
  final GlobalKey<ScaffoldState> _scaffoldstate =
  new GlobalKey<ScaffoldState>();
  bool downloading = false;
  bool uploadLoading = false;
  var progress = "";
  static final Random random = Random();
  var path = "No Data";
  var _onPressed;
  Future futureAlbum;
  var dropdownValue = 'Addis Ababa';
  var dropdownValue2 ='Admin';
  var courseId;
  var classId;
  var sectionId;
  var sex;
  var error;
  bool isFNameNotfill=false;
  bool ispasswordsNotmatch=false;
  bool isLNameNotfill=false;
  bool isSexNotfill=false;
  bool isEmailNotfill=false;
  bool isPhoneNotfill=false;
  bool isPaswordNotfill=false;
  bool isConfirmPaswordNotfill=false;
  bool isCourseNotfill=false;
  bool isClassNotfill=false;
  bool isSectionNotfill=false;
  bool isFileNotfill=false;
  bool isErrorHappened=false;

  bool isCoursesLoading= false;
  bool isClassLoading= false;
  bool isSectionLoading= false;
  changeOrderType( newValue){
    setState(() {
      dropdownValue = newValue;
      dropdownValue2= newValue;
    });
  }
  List sexList=[
    {"TypeView":"Male","Type":"Male"}, {"TypeView":"Female","Type":"Female"}
  ];
  List courses = [];
  List classList=[];
  List section=[];
  bool isLoading = false;
  bool timeoutException =false;
  bool socketException = false;
  bool catchException = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetchclass();
    this.fetchSection();


  }


  fetchclass() async {
    setState(() {
      isClassLoading = true;
    });
    int timeout=20;
    try
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url = Uri.parse("$httpUrl/api/allClasses");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          classList = items;
          isClassLoading = false;
        });
      }
      else {
        setState(() {
          classList = [];
          isClassLoading = false;
        });
      }
    }
    on TimeoutException catch (e) {
      print('Timeout Error: $e');
      setState(() {
        isClassLoading = false;
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
        isClassLoading = false;

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
        isClassLoading = false;
        catchException = true;
      });
      Fluttertoast.showToast(
          msg: "error occurred while loading",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);

    }
  }
  fetchSection() async {
    setState(() {
      isSectionLoading = true;
    });
    int timeout=20;
    try
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url = Uri.parse("$httpUrl/api/sections");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          section = items;
          isSectionLoading = false;
        });
        Fluttertoast.showToast(
            msg: "connection timeout, try again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      }
      else {
        setState(() {
          section = [];
          isSectionLoading = false;
        });
      }
    }
    on TimeoutException catch (e) {
      print('Timeout Error: $e');
      setState(() {
        isSectionLoading = false;
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
        isSectionLoading = false;

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
        isSectionLoading = false;
        catchException = true;
      });
      Fluttertoast.showToast(
          msg: "error occurred while loading",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);

    }
  }
  finishRegister() async {
    setState(() {
      isLoading = true;
    });
    int timeout=20;
    try
    {

      var url = Uri.parse("$httpUrl/api/registerStudent");
      var response = await http.post(url, headers: {
        'Accept': 'application/json',
      }, body: {
        "f_name": "${f_nameController.text}",
        "l_name": "${l_nameController.text}",
        "email": "${emailController.text}",
        "phone_no": "${phoneController.text}",
        "password": "${passwordController.text}",
        "sex": "$sex",
        "class_id": "$classId",
        "section_id": "$sectionId",
      }).timeout(Duration(seconds: timeout));
      print(response.statusCode);
      if (response.statusCode == 201 || response.statusCode==200) {
        var items = json.decode(response.body);
        print("${response.statusCode}");
        print("${response.body}");

        setState(() {
          isLoading = false;
        });
        Navigator.pop(this.context, true);
      }
      else if (response.statusCode == 421 || response.statusCode == 422)
      {
        if(json.decode(response.body)['errors']['email']!=null )
        {
        error=json.decode(response.body)['errors']['email'];
        print("${response.statusCode}");
        setState(() {
          isLoading = false;
          isErrorHappened=true;
        });}
      }
      else {
        print("${response.statusCode}");
        print("${response.body}");
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "The given data was invalid",
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    if (isCoursesLoading || isClassLoading || isSectionLoading || isLoading) {
      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, true);
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text('Register'),
            ),
            body: Center(
                child: const SpinKitDoubleBounce(size: 71.0, color: Color(0xff229546)))),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Register'),
        ),
        body: Center(
          child: Center(

              child: ListView(
                children: <Widget>[

                  textSection(),
                  buttonSection(),
                  SizedBox(
                    height: 15,
                  ),
                ],
              )

          ),
        ),
      ),
    );
  }
  //-----------------------------------upload solutions---------------------------



  Future<Null> refreshList() async {
    setState(() {

    });
  }
  Container buttonSection() {
    return Container(
      width: MediaQuery.of(this.context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: () {

          setState(() {
            isLoading=true;
            isFNameNotfill = false;
            ispasswordsNotmatch=false;
            isLNameNotfill = false;
            isSexNotfill= false;
            isEmailNotfill = false;
            isPhoneNotfill = false;
            isPaswordNotfill = false;
            isConfirmPaswordNotfill = false;
            isClassNotfill= false;
            isSectionNotfill= false;
            isFileNotfill=false;
            isErrorHappened=false;
          });

          if(classId!=null  && sectionId!=null && sex!=null && f_nameController.text!='' && f_nameController.text!='' &&
              emailController.text!='' && phoneController.text!='' && passwordController.text!='' && ConfirmpasswordController.text!='' && passwordController.text==ConfirmpasswordController.text) {
            setState(() {
              finishRegister();
            });
            setState(() {
              isFNameNotfill = false;
              ispasswordsNotmatch=false;
              isLNameNotfill = false;
              isSexNotfill= false;
              isEmailNotfill = false;
              isPhoneNotfill = false;
              isPaswordNotfill = false;
              isConfirmPaswordNotfill = false;
              isClassNotfill= false;
              isSectionNotfill= false;
              isFileNotfill=false;
            });
          }
          else if(passwordController.text!=ConfirmpasswordController.text){
          Fluttertoast.showToast(
          msg: "Those passwords didn’t match. Try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);

          setState(() {
          isLoading = false;
          ispasswordsNotmatch=true;
          ConfirmpasswordController..text='';
          });
          }
          else{
            if(f_nameController.text==''){
              setState(() { isFNameNotfill =true;});
            }
            if(l_nameController.text==''){
              setState(() { isLNameNotfill =true;});
            }
            if(sex==null){
              setState(() { isSexNotfill =true;});
            }
            if(emailController.text==''){
              setState(() { isEmailNotfill =true;});
            }
            if(phoneController.text==''){
              setState(() { isPhoneNotfill =true;});
            }
            if(passwordController.text==''){
              setState(() { isPaswordNotfill =true;});
            }
            if(ConfirmpasswordController.text==''){
              setState(() { isConfirmPaswordNotfill =true;});
            }
            if(classId==null){
              setState(() { isClassNotfill =true;});
            }
            if(sectionId==null){
              setState(() { isSectionNotfill =true;});
            }

            if(file==null){
              setState(() { isFileNotfill =true;});
            }
            setState(() {
              isLoading = false;
            });
          }

        },
        elevation: 0.0,
        disabledColor: Color(0x6f229546),
        disabledTextColor: Colors.white54,
        color: Color(0xff229546),
        child: Text("Submit", style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }
  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'Choose Course, Class and Section you teach',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Color(0xff229546),
                      letterSpacing: .5,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),),
              ],
            )),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Divider(
                color: Color(0x3f229546)
            ),
          ),

          Row(
            children: [
              Container(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text.rich(TextSpan(
                    children: <TextSpan>[

                      TextSpan(text: '*',style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize:18)),
                      TextSpan(text:'F Name', style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      ),),
                    ],
                  )),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  child: TextFormField(
                      controller: f_nameController,

                      cursorColor: Color(0xff229546),
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "First Name...",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.5,
                            color: Colors.black26,
                          ),
                          filled: true,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          fillColor: Colors.white.withOpacity(.3),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ))
                  ),
                ),
              ),
            ],
          ),
          if( isFNameNotfill)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'The F Name field is required',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Divider(
                color: Color(0x3f229546)
            ),
          ),
          Row(
            children: [
              Container(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text.rich(TextSpan(
                    children: <TextSpan>[

                      TextSpan(text: '*',style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize:18)),
                      TextSpan(text:'L name', style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      ),),
                    ],
                  )),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  child: TextFormField(
                      controller: l_nameController,

                      cursorColor: Color(0xff229546),
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Last Name...",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.5,
                            color: Colors.black26,
                          ),
                          filled: true,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          fillColor: Colors.white.withOpacity(.3),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ))
                  ),
                ),
              ),
            ],
          ),
          if( isLNameNotfill)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'The L Name field is required',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Divider(
                color: Color(0x3f229546)
            ),
          ),
          Row(
            children: [
              Container(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text.rich(TextSpan(
                    children: <TextSpan>[

                      TextSpan(text: '*',style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize:18)),
                      TextSpan(text:' Type', style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      ),),
                    ],
                  )),
                ),
              ),
              Expanded(
                child:
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Color(0xff229546)),
                        left: BorderSide(width: 1.0, color: Color(0xff229546)),
                        right: BorderSide(width: 1.0, color: Color(0xff229546)),
                        bottom: BorderSide(width: 1.0, color: Color(0xff229546)),
                      ),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),

                  // dropdown below..
                  child: new DropdownButton(
                    items: sexList.map((item) {
                      return new DropdownMenuItem(
                        child: new Text(item['TypeView']),
                        value: item['Type'],
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      setState(() {
                        sex = newVal;

                      });
                    },
                    value: sex,

                  ),
                ),



              )],
          ),
          if( isSexNotfill)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'The sex field is required',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Divider(
                color: Color(0x3f229546)
            ),
          ),
          Row(
            children: [
              Container(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text.rich(TextSpan(
                    children: <TextSpan>[

                      TextSpan(text: '*',style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize:18)),
                      TextSpan(text:'Email', style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      ),),
                    ],
                  )),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  child: TextFormField(
                      controller: emailController,

                      cursorColor: Color(0xff229546),
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Email...",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.5,
                            color: Colors.black26,
                          ),
                          filled: true,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          fillColor: Colors.white.withOpacity(.3),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ))
                  ),
                ),
              ),
            ],
          ),
          if( isEmailNotfill)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'The Email field is required',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Divider(
                color: Color(0x3f229546)
            ),
          ),

          Row(
            children: [
              Container(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text.rich(TextSpan(
                    children: <TextSpan>[

                      TextSpan(text: '*',style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize:18)),
                      TextSpan(text:'Phone ', style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      ),),
                    ],
                  )),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      cursorColor: Color(0xff229546),
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Phone...",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.5,
                            color: Colors.black26,
                          ),
                          filled: true,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          fillColor: Colors.white.withOpacity(.3),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ))
                  ),
                ),
              ),
            ],
          ),
          if( isPhoneNotfill)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'The Phone field is required',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Divider(
                color: Color(0x3f229546)
            ),
          ),

          Row(
            children: [
              Container(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text.rich(TextSpan(
                    children: <TextSpan>[

                      TextSpan(text: '*',style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize:18)),
                      TextSpan(text:'Password', style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      ),),
                    ],
                  )),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  child: TextFormField(
                      controller: passwordController,

                      cursorColor: Color(0xff229546),
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Password...",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.5,
                            color: Colors.black26,
                          ),
                          filled: true,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          fillColor: Colors.white.withOpacity(.3),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ))
                  ),
                ),
              ),
            ],
          ),
          if( isPaswordNotfill)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'The Password field is required',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Divider(
                color: Color(0x3f229546)
            ),
          ),

          Row(
            children: [
              Container(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text.rich(TextSpan(
                    children: <TextSpan>[

                      TextSpan(text: '*',style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize:18)),
                      TextSpan(text:'Confirm Password', style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      ),),
                    ],
                  )),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  child: TextFormField(
                      controller: ConfirmpasswordController,

                      cursorColor: Color(0xff229546),
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Confirm Password...",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.5,
                            color: Colors.black26,
                          ),
                          filled: true,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          fillColor: Colors.white.withOpacity(.3),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff229546)),
                            borderRadius: BorderRadius.circular(10),
                          ))
                  ),
                ),
              ),
            ],
          ),
          if( isConfirmPaswordNotfill)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'The Confirm Password field is required',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),
          if( ispasswordsNotmatch)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: "Those passwords didn’t match. Try again.",
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Divider(
                color: Color(0x3f229546)
            ),
          ),

          Row(
            children: [
              Container(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text.rich(TextSpan(
                    children: <TextSpan>[

                      TextSpan(text: '*',style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize:18)),
                      TextSpan(text:' Class', style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      ),),
                    ],
                  )),
                ),
              ),
              Expanded(
                child:  Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Color(0xff229546)),
                        left: BorderSide(width: 1.0, color: Color(0xff229546)),
                        right: BorderSide(width: 1.0, color: Color(0xff229546)),
                        bottom: BorderSide(width: 1.0, color: Color(0xff229546)),
                      ),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),

                  // dropdown below..
                  child: new DropdownButton(
                    items: classList.map((item) {
                      return new DropdownMenuItem(
                        child: new Text(item['class_name']),
                        value: item['id'].toString(),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      setState(() {
                        classId = newVal;
                        print(classId);
                      });
                    },
                    value: classId,

                  ),
                ),
              ),


            ],
          ),

          if( isClassNotfill)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'The class field is required',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Divider(
                color: Color(0x3f229546)
            ),
          ),
          Row(
            children: [
              Container(
                width: 130,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text.rich(TextSpan(
                    children: <TextSpan>[

                      TextSpan(text: '*',style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize:18)),
                      TextSpan(text:' Section', style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontSize: 16,
                        ),
                      ),),
                    ],
                  )),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Color(0xff229546)),
                        left: BorderSide(width: 1.0, color: Color(0xff229546)),
                        right: BorderSide(width: 1.0, color: Color(0xff229546)),
                        bottom: BorderSide(width: 1.0, color: Color(0xff229546)),
                      ),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),

                  // dropdown below..
                  child: new DropdownButton(
                    items: section.map((item) {
                      return new DropdownMenuItem(
                        child: new Text(item['section_name']),
                        value: item['id'].toString(),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      setState(() {
                        sectionId = newVal;
                        print(sectionId);
                      });
                    },
                    value: sectionId,

                  ),
                ),
              ),

            ],
          ),
          if( isSectionNotfill)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'The section field is required',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),),
              ],
            )),

          if( isErrorHappened)
            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '$error',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.red,
                      letterSpacing: .5,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),),
              ],
            )),
        ],
      ),
    );
  }
}


