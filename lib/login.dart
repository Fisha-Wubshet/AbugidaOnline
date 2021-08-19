import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abugida_online/utils/ObscuringTextEditingController.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;

  var _phone;
  var _password;
  @override
  void initState() {
    phoneController.addListener(_onTipEmailChanged);
    passwordController.addListener(_onTipPasswordChanged);
    super.initState();
  }

  _onTipEmailChanged() {
    setState(() {
      _phone = phoneController.text;
      _password = passwordController.text;
    });
  }

  _onTipPasswordChanged() {
    setState(() {
      _phone = phoneController.text;
      _password = passwordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [
                0.1,
                0.3,
                0.6,
                0.9
              ],
                  colors: [
                Color(0xffFCF9F5),
                Color(0xffFCF9F5),
                Color(0xffFCF9F5),
                Color(0xffFCF9F5),
              ])),
          child: Center(
            child: Column(
              children: <Widget>[
                headerSection(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Material(
                    color: Color(0xff82C042),
                    elevation: 14,
                    shadowColor: Color(0x802196F3),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0)),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20.0),
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0)),
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              stops: [
                                0.1,
                                0.4,
                                0.6,
                                0.9
                              ],
                              colors: [
                                Color(0xff229546),
                                Color(0xff93CA67),
                                Color(0xff941A67),
                                Color(0xff93CA67),
                              ])),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              textSection(),
                              buttonSection(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  signIn(phone, String pass) async {
    setState(() {
      _isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var url = Uri.parse("$httpUrl/api/getStudentToken");
      var response = await http.post(url, headers: {
        'Accept': 'application/json',
      }, body: {
        "email": "$phone",
        "password": "$pass"
      }).timeout(Duration(seconds: timeout));
      print('{${response.body}');
      if (response.statusCode == 200) {
        //=========================================wrong credentials=============================
        if (response.body == "wrong credentials") {
          Fluttertoast.showToast(
              msg: "${response.body}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
          setState(() {
            _isLoading = false;
          });
        }
        //=========================================Login=============================
        else {
          var jsonResponse = json.decode(response.body);
          print("${response.statusCode}");
          print("${response.body}");
          if (jsonResponse != null) {
            setState(() {
              _isLoading = false;
            });
            sharedPreferences.setString('token', jsonResponse["token"]);

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => HomePage()),
                (Route<dynamic> route) => false);
          }
        }
      }
      if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "${response.body}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        setState(() {
          _isLoading = false;
        });
        print(response.body);
        print(response.statusCode);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      setState(() {
        _isLoading = false;
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
        _isLoading = false;

        socketException = true;
      });
      Fluttertoast.showToast(
          msg: "no connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
      print(_isLoading);
    } on Error catch (e) {
      print('$e');
      setState(() {
        _isLoading = false;
        catchException = true;
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
        onPressed: _phone == "" || _isLoading || _password == ""
            ? null
            : () {
                signIn(_phone, _password);
              },
        elevation: 0.0,
        color: Color(0xff82C042),
        child: Text.rich(TextSpan(
          children: <TextSpan>[
            if (!_isLoading)
              TextSpan(text: "Sign In", style: TextStyle(color: Colors.white)),
            if (_isLoading)
              TextSpan(text: ' ...', style: TextStyle(color: Colors.white)),
          ],
        )),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController passwordController =
      new ObscuringTextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: phoneController,
            cursorColor: Color(0xff82C042),
            style: TextStyle(color: Color(0xff82C042)),
            decoration: InputDecoration(
                fillColor: Colors.white,
                prefixIcon: Icon(
                  Icons.phone_android,
                  color: Color(0xff82C042),
                  size: 15,
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff82C042)),
                  borderRadius: BorderRadius.circular(25),
                ),
                hintText: 'Email',
                hintStyle: TextStyle(
                  fontSize: 15,
                  letterSpacing: 1.5,
                  color: Color(0xff82C042),
                ),
                filled: true,
                hoverColor: Color(0xff82C042),
                focusColor: Color(0xff82C042),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightGreen[200]),
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff82C042)),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50.0),
                      topLeft: Radius.circular(50.0),
                      bottomLeft: Radius.circular(50.0),
                      bottomRight: Radius.circular(50.0)),
                )),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Color(0xff82C042),
            enableSuggestions: false,
            autocorrect: false,
            style: TextStyle(color: Color(0xff82C042)),
            decoration: InputDecoration(
                fillColor: Colors.white,
                prefixIcon: Icon(
                  Icons.vpn_key_rounded,
                  color: Color(0xff82C042),
                  size: 15,
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff82C042)),
                  borderRadius: BorderRadius.circular(25),
                ),
                hintText: "Password",
                hintStyle: TextStyle(
                  fontSize: 15,
                  letterSpacing: 1.5,
                  color: Color(0xff82C042),
                ),
                filled: true,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff82C042)),
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff82C042)),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50.0),
                      topLeft: Radius.circular(50.0),
                      bottomLeft: Radius.circular(50.0),
                      bottomRight: Radius.circular(50.0)),
                )),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 30.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Stack(
        children: <Widget>[
          Center(
              child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    blurRadius: 10, color: Colors.black12, spreadRadius: 5)
              ],
            ),
            child: CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('assets/Trillium.jpg'),
            ),
          )),
        ],
      ),
    );
  }
}
