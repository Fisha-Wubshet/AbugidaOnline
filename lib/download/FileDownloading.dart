import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:file_utils/file_utils.dart';
import 'dart:math';



class FileDownloader extends StatefulWidget {
  @override
  _FileDownloaderState createState() => _FileDownloaderState();
}

class _FileDownloaderState extends State<FileDownloader> {

  final imgUrl = "https://demo.trillium-elearing.com/storage/materials/Photosynthesis_1606674159.pdf";
  bool downloading = false;
  var progress = "";
  var path = "No Data";
  var platformVersion = "Unknown";
  var _onPressed;
  static final Random random = Random();
  Directory externalDir;

  @override
  void initState() {
    super.initState();
    _createFolder();
  }
  _createFolder()async{
    final folderName="Assignment";
    final path= Directory("storage/emulated/0/$folderName");
    if ((await path.exists())){
      // TODO:
      print("exist");
    }else{
      // TODO:
      print("not exist");
      path.create();
    }}


  Future<void> downloadFile() async {
    Dio dio = Dio();
    bool checkPermission1 =true;

    // print(checkPermission1);
    if (checkPermission1 == false) {

    }
    if (checkPermission1 == true) {
      String dirloc = "";
      if (Platform.isAndroid) {
        dirloc = "storage/emulated/0/Assignment/";
      } else {
        dirloc = (await getApplicationDocumentsDirectory()).path;
      }

      var randid = random.nextInt(10000);

      try {
        FileUtils.mkdir([dirloc]);
        await dio.download(imgUrl, dirloc + randid.toString() + ".pdf",
            onReceiveProgress: (receivedBytes, totalBytes) {
              setState(() {
                downloading = true;
                progress =
                    ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
              });
            });
      } catch (e) {
        print(e);
      }

      setState(() {
        downloading = false;
        progress = "Download Completed.";
        path = dirloc + randid.toString() + ".pdf";
      });
    } else {
      setState(() {
        progress = "Permission Denied!";
        _onPressed = () {
          downloadFile();
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('File Downloader'),
      ),
      body: Center(
          child: downloading
              ? Container(
            height: 120.0,
            width: 200.0,
            child: Card(
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'Downloading File: $progress',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(path),
              MaterialButton(
                child: Text('Request Permission Again.'),
                onPressed: () {
                  downloadFile();

                },
                disabledColor: Colors.blueGrey,
                color: Colors.pink,
                textColor: Colors.white,
                height: 40.0,
                minWidth: 100.0,
              ),
            ],
          )));
}