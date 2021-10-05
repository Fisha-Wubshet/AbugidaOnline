import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/src/gestures/tap.dart';


class DownloadList extends StatefulWidget {
  @override
  _DownloadListState createState() => _DownloadListState();
}
class LinkTextSpan extends TextSpan {
  LinkTextSpan({TextStyle style, String url, String text})
      : super(
      style: style,
      text: text ?? url,
      recognizer: new TapGestureRecognizer()
        ..onTap = () {
          launch(url);
        });
}
class _DownloadListState extends State<DownloadList> {
  var _openResult = 'Unknown';

  _launchURL() async {
    const url = 'https://demo.trillium-elearing.com/storage/materials/pic1.jpg';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10,20, 8),
            child: GestureDetector(
              onTap:  () =>{_launchURL()} ,
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
                          'Resource',  style: GoogleFonts.fredokaOne(
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
      ),
    );
  }
}