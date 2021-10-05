import 'dart:convert';

import 'package:abugida_online/utils/httpUrl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';



class UploadSolution extends StatefulWidget {
  final as_status;
  final as_id;

  UploadSolution({
    this.as_status,
    this.as_id
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _UploadSolutionState createState() => _UploadSolutionState();
}

class _UploadSolutionState extends State<UploadSolution> {
  int _counter = 0;
  File _image;
  File file;
  final GlobalKey<ScaffoldState> _scaffoldstate =
  new GlobalKey<ScaffoldState>();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    _uploadFile(image);

    setState(() {
      _image = image;
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  // Methode for file upload
  Future filepick() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );
    print('ghfjdksodjjdkjhjdkdjfdkjn------------------------------------');

    if (result != null) {
      file = File(result.files.single.path);
      print(file);
      _uploadFile(file);
    }
  }
  void _uploadFile(filePath) async {

    // Get base file name
    String fileName = basename(filePath.path);
    print("File base name: $fileName");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    var stream = new http.ByteStream(DelegatingStream.typed(filePath.openRead()));
    // get file length
    var length = await filePath.length();

    // string to uri
    var uri = Uri.parse("$httpUrl/api/uploadMySolution");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    request.headers['authorization'] = "Bearer $token";
    request.headers['Content-Type'] = "multipart/form-data";
    request.fields['as_id'] = '${widget.as_id}';
    // multipart that takes file
    var multipartFile = new http.MultipartFile('sol_file', stream, length,
        filename: basename(filePath.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  // Method for showing snak bar message
  void _showSnakBarMsg(String msg) {
    _scaffoldstate.currentState
        .showSnackBar(new SnackBar(content: new Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(

      appBar: AppBar(

        title: Text('sdfgh'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _image == null ? Text('No image selected.') : Image.file(_image),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: (){Navigator.of(context).pop();
      showDialog(
      context: this.context,
      builder: (BuildContext context ) => _fileChoose(context, widget.as_id),
      );},
        tooltip: 'Increment',
        label: const Text('Upload Solution'),
        icon: const Icon(Icons.upload_file),



      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Widget _fileChoose(BuildContext context, id) {
    return new AlertDialog(
      title: const Text('', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 2)),

      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Divider(color: Color(0xff229546)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: GestureDetector(
                onTap: () {
                  getImage();
                },
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Color(0xff229546),),
                      Text(
                        '  Camera',  style: GoogleFonts.roboto(
                        textStyle: TextStyle(color: Color(0xff000000), fontSize: 20, shadows: <Shadow>[
                          Shadow(
                            offset: Offset(1.5, 1.5),
                            blurRadius: 3.0,
                            color: Color(0x2D7BA0E0),
                          ),
                        ],fontWeight: FontWeight.bold),),),
                    ],),),),),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Divider(color: Color(0xff229546)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: GestureDetector(
                onTap: () {
                  filepick();
                },
                child: Align(
                  alignment: Alignment.center,

                  child: Center(
                    child: Align(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, color: Color(0xff229546),),
                          Text(
                            '  File',  style: GoogleFonts.roboto(
                            textStyle: TextStyle(color: Color(0xff000000), fontSize: 20, shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.5, 1.5),
                                blurRadius: 3.0,
                                color: Color(0x2D7BA0E0),
                              ),
                            ],fontWeight: FontWeight.bold),),),
                        ],),),),),),),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Divider(color: Color(0xff229546)),
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