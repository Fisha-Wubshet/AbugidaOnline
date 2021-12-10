import 'dart:async';
import 'dart:io';

import 'package:abugida_online/database_helper.dart';
import 'package:abugida_online/login.dart';
import 'package:abugida_online/utils/ObscuringTextEditingController.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import '../main.dart';

class NewPassword extends StatefulWidget {
  final Phone;

  NewPassword({
    this.Phone,
  });
  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  var _pin;
  var _pin2;
  var _pinOld;
  @override
  void initState() {
    pinController.addListener(_onTipPinChanged);
    pin2Controller.addListener(_onTipPin2Changed);
    pinOldController.addListener(_onTipPinOldChanged);
    super.initState();
  }

  _onTipPinChanged() {
    setState(() {
      _pin = pinController.text;
      _pin2 = pin2Controller.text;
      _pinOld= pinOldController.text;
    });
  }

  _onTipPin2Changed() {
    setState(() {
      _pin = pinController.text;
      _pin2 = pin2Controller.text;
      _pinOld= pinOldController.text;
    });
  }
  _onTipPinOldChanged() {
    setState(() {
      _pin = pinController.text;
      _pin2 = pin2Controller.text;
      _pinOld= pinOldController.text;
    });
  }
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: AppBar(
          title: Text('New Password'), backgroundColor: Color(0xff229546)),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: _isLoading
            ? Center(
            child:
            const SpinKitDoubleBounce(size: 71.0, color: Color(0xff229546)))
            : ListView(
          children: <Widget>[
            textSection(),
            buttonSection(),
          ],
        ),
      ),
    );
  }

  ResetPassword(pin, Oldpin) async {
    int timeout = 20;
    try {
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');
      var url =
      Uri.parse("$httpUrl/api/resetPassword");
      var response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
          "new_password":"$pin",
          "old_password":"$Oldpin"
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print("${response.statusCode}");
        print("${response.body}");
        if (jsonResponse != null) {
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(
              msg: "successfully Changed your password",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
          await VerificationDatabaseHelper.instance.delete(1);
          await VerificationDatabaseHelper.instance.delete(2);
          await VerificationDatabaseHelper.instance.delete(3);
          await VerificationDatabaseHelper.instance.delete(4);
          var queryRows =
          await VerificationDatabaseHelper.instance.queryAllRows();
          print(queryRows);
          SharedPreferences preferences =
          await SharedPreferences.getInstance();
          await preferences.clear();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage()),
                  (Route<dynamic> route) => false);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: response.body,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "connection timeout, try again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } on SocketException catch (e) {
      print('Socket Error: $e');
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "no connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } on Error catch (e) {
      print('$e');
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "error occurred while loading",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: pinController.text == "" || pin2Controller.text == "" || pinOldController.text == ""
            ? null
            : () {
          setState(() {
            _isLoading = true;
          });
          if (pinController.text == pin2Controller.text) {
            ResetPassword( pinController.text, pinOldController.text);
          } else {
            Fluttertoast.showToast(
                msg: "password are not matching",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1);
            pinController..text = '';
            pin2Controller..text = '';
            setState(() {
              _isLoading = false;
            });
          }
        },
        elevation: 0.0,
        disabledColor: Color(0x6f229546),
        disabledTextColor: Colors.white54,
        color: Color(0xff229546),
        child: Text("Confirm", style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  final TextEditingController pinController =
  new ObscuringTextEditingController();
  final TextEditingController pin2Controller =
  new ObscuringTextEditingController();
  final TextEditingController pinOldController =
  new ObscuringTextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                TextSpan(
                    text: 'Old Password',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            )),
          ),
          TextFormField(
              controller: pinOldController,
              cursorColor: Color(0xff229546),
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff229546)),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  hintText: "Old password...",
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
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff229546)),
                    borderRadius: BorderRadius.circular(25),
                  ))),
          SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                TextSpan(
                    text: 'new password',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            )),
          ),
          TextFormField(
              controller: pinController,
              cursorColor: Color(0xff229546),
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff229546)),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  hintText: "password...",
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
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff229546)),
                    borderRadius: BorderRadius.circular(25),
                  ))),
          SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                TextSpan(
                    text: 'Confirm Password',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            )),
          ),
          TextFormField(
              controller: pin2Controller,
              cursorColor: Color(0xff229546),
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff229546)),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  hintText: "Password",
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
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff229546)),
                    borderRadius: BorderRadius.circular(25),
                  ))),
        ],
      ),
    );
  }
}
