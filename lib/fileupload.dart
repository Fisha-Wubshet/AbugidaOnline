import 'dart:convert';

import 'package:abugida_online/utils/httpUrl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';



class fileUpload extends StatefulWidget {
  fileUpload({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _fileUploadState createState() => _fileUploadState();
}

class _fileUploadState extends State<fileUpload> {
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
    request.fields['as_id'] = '693';
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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('sdfgh'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _image == null ? Text('No image selected.') : Image.file(_image),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
          onPressed: filepick,
          tooltip: 'Increment',
          label: const Text('Upload Solution'),
          icon: const Icon(Icons.upload_file),



        ),
    // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}