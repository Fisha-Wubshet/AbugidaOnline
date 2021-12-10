import 'dart:math';

import 'package:abugida_online/ImageViewer/ImageViewer.dart';
import 'package:abugida_online/Quiz/QuizChoice.dart';
import 'package:abugida_online/assignment/OnlineAssignment.dart';
import 'package:abugida_online/assignment/SubmissionAnswer.dart';
import 'package:abugida_online/assignment/uploadSolution.dart';
import 'package:abugida_online/pdftest.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:abugida_online/webview.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';

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
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';


class Assignment extends StatefulWidget {
  final course_id;
  final course_name;

  Assignment({
    this.course_id,
    this.course_name,
  });

  @override
  _AssignmentState createState() => _AssignmentState();
}

class _AssignmentState extends State<Assignment>with SingleTickerProviderStateMixin {
  List users = [];
  int _counter = 0;
  File _image;
  File file;
  final GlobalKey<ScaffoldState> _scaffoldstate =
  new GlobalKey<ScaffoldState>();
  bool downloading = false;
  bool uploadLoading = false;
  var progress = "";
  static final Random random = Random();
  var path = "No Data";
  var _onPressed;
  bool isLoading = false;
  bool checkemptyList= false;
  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;
  bool checkPermission1;
  TabController controller;
  @override
  void initState() {
    // TODO: implement initState
    controller=new TabController(length: 2, vsync: this);
    super.initState();
    this.fetchUser();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  _getRequests() async {
    setState(() {
        isLoading = true;
        refreshList();
    });
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
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //text
                  SizedBox(
                    width: MediaQuery.of(this.context).size.width * 0.8,
                    child: Text(
                      '${widget.course_name} Assignment',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredokaOne(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xffffffff),
                          letterSpacing: 2,
                          fontSize: 20,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 5.0,
                              color: Color(0x48000000),
                            ),
                          ],
                        ),
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

  Future<void> downloadFile(title, urlPath) async {

    checkPermission1= (await Permission.manageExternalStorage.status).isGranted;
   bool checkPermission= (await Permission.storage.status).isGranted;
    Dio dio = Dio();

    var mimeType = lookupMimeType(urlPath);
    var filetypeexten= urlPath.split(".");
    print(filetypeexten[filetypeexten.length-1]);
    // print(checkPermission1);
    if (checkPermission1 == false && checkPermission == false) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();

      checkPermission1=(await Permission.manageExternalStorage.status).isGranted;
      checkPermission= (await Permission.storage.status).isGranted;
    }
    if (checkPermission1 == true || checkPermission== true) {
      String dirloc = "";
      if (Platform.isAndroid) {
        dirloc = "storage/emulated/0/Assignment/";
      } else {
        dirloc = (await getApplicationDocumentsDirectory()).path;
      }

      var randid = '${title}  _${random.nextInt(10000)}';

      try {
        FileUtils.mkdir([dirloc]);
        await dio.download('$httpUrl$urlPath', dirloc + randid.toString() + ".${filetypeexten[filetypeexten.length-1]}",
            onReceiveProgress: (receivedBytes, totalBytes) {
              setState(() {
                downloading = true;
                progress =
                    ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
              });
            });
        setState(() {
          downloading = false;
          progress = "Download Completed.";
          path = dirloc + randid.toString();
          Fluttertoast.showToast(
              msg: 'Successfully downloaded $path',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);


        });
      } catch (e) {
        print(e);
        setState(() {
          downloading = false;

          Fluttertoast.showToast(
              msg: 'download failed',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        });
      }


    } else {
      setState(() {
        progress = "Permission Denied!";
        _onPressed = () {
          downloadFile(title, '$httpUrl$urlPath');
        };
      });
    }
  }
  //-----------------------------------upload solutions---------------------------

  Future getImage(id, title) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    _uploadFile(image, id, title);

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
  Future filepick(id, title) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg','jpeg', 'png', 'pdf', 'doc', 'docx','pptx', 'ppt',  ],
    );
    print('ghfjdksodjjdkjhjdkdjfdkjn------------------------------------');

    if (result != null) {
      file = File(result.files.single.path);
      print(file);
      _uploadFile(file, id, title);
    }
  }
  void _uploadFile(filePath, id, title) async {
    Navigator.of(this.context).pop();
    setState(() {
      uploadLoading = true;
    });
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
    request.fields['as_id'] = '$id';
    // multipart that takes file
    var multipartFile = new http.MultipartFile('sol_file', stream, length,
        filename: basename(filePath.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);
    if(response.statusCode==201 || response.statusCode==200) {

      Fluttertoast.showToast(
          msg: "you are successfully uploaded your solution",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
      setState(() {
        uploadLoading = false;
        refreshList();
      });
      Navigator.push(
          this.context,
          MaterialPageRoute(
              builder: (context) => new SubmissionAnswer(
                  Assignment_id:id,
                  Assignment_name:title
              )));
    }
    else {
      Fluttertoast.showToast(
          msg: "uploaded failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
      setState(() {
        uploadLoading = false;
      });
    }
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

  //--------------------------------------------------------------
  fetchUser() async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url =
      Uri.parse("$httpUrl/api/showCourseAssignments/${widget.course_id}");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          users = items;
          print('fghjklffffffffffffffffffffffff');
          print(users.length==0);
          if(users.length==0)
          {
            checkemptyList = true;
          }
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
          users = [];
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

  Future<Null> refreshList() async {
    setState(() {
      fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            new TabBar(
              controller: controller,
              indicatorWeight: 2.0,
              indicatorColor: Color(0xffffffff),
              tabs:<Widget> [
                new Tab (icon: new Text("Not graded",
                  style: TextStyle(fontWeight: FontWeight.w900,color: Color(0xffffffff),
                    fontSize: 15, shadows: <Shadow>[Shadow(offset: Offset(2.0, 2.0), blurRadius: 5.0, color: Color(0x48000000),),],), )),
                new Tab (icon: new Text("graded", style: TextStyle(fontWeight: FontWeight.w900,color: Color(0xffffffff),
                  fontSize: 15, shadows: <Shadow>[Shadow(offset: Offset(2.0, 2.0), blurRadius: 5.0, color: Color(0x48000000),),],), )),


              ],

            ),
          ],
        ),
      ),

      body: new TabBarView(
        controller: controller,
        children: <Widget>[

          new Scaffold(

            body: RefreshIndicator(onRefresh: refreshList, child: getBodyNotGraded()),
          ),
          new Scaffold(
            body: RefreshIndicator(onRefresh: refreshList, child:getBodyGraded()),
          ),
        ],
      ),
    );
  }

  Widget getBodyGraded() {
    if (isLoading) {
      return Center(
          child: const SpinKitDoubleBounce(size: 71.0, color: Color(0xff229546)));
    }
    if (socketException || timeoutException) {
      return Center(

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/animation.png'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: Icon(
                        Icons.sync,
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
                )
              ],
            ),
          ));
    }

    if(uploadLoading){
      return Material(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Uploading '),
              SpinKitThreeBounce(
                color: Color(0xff229546),
                size: 30,
              ),
            ],
          ));
    }
    if(users.length==0) {
      return Center(
        child: SingleChildScrollView(
          child: Container(
            width: 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 300,
                  child: Image(image: AssetImage('assets/Nocontant.png'),),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return downloading
        ? Center(
      child: Container(
        height: 120.0,
        width: 200.0,
        child: Card(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:  CrossAxisAlignment.center,
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
      ),
    )
        : ListView.builder(

              itemCount: users.length,
              itemBuilder: (context, index) {
                return getGraded(users[index]);
              }

    );
  }

  Widget getGraded(item) {
    var name = item['as_title'];

    var type = item['as_type'];
    var result = item["score"];
    var value = item["value"];
    //==================================
    var post = item['posted'];
    var deadline = item['deadline'];
    var value_type = item['value_type'];

    if(item['score_status']=='Graded')
    return InkWell(
      onTap: () {

        if(item['as_type']!='ONLINE_ASSIGNMENT')
        {
          print(item['id']);
          showDialog(
            context: this.context,
            builder: (BuildContext context ) => _buildrequestPopupDialog(context,  item['as_title'], item['as_loc'], item['id'],item['as_status'], item['submission_status'], item['score_status'], item['score']),
          );
          final mimeType = lookupMimeType(item['as_loc']);

          if (mimeType == 'image/png' ||
              mimeType == 'image/jpeg' ||
              mimeType == 'image/jpg ') {
            print(mimeType);
            print(item['as_loc']);
          }
        }
        else{
          print(item['id']);
          showDialog(
          context: this.context,
          builder: (BuildContext context ) => _buildonlineexamPopupDialog(context,item['id'], item['as_title'], item['value'],item['posted'], item['deadline'],  item['as_status'], item['take_status'], item['value_type'], item['score_status'], item['score'],),
        );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Card(
          elevation: 3,
          shadowColor: Color(0x502196F3),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
            child: ListTile(
              leading: Icon(Icons.library_books, color:
              type=='DOWNLOADABLE_ASSIGNMENT'? Color(0xff3c8dcb): Color(0xff229546)),
              title:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(this.context).size.width - 140,
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: name,
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
                      if(value_type=='VALUABLE')

                      Text(
                        'Score: $result Assessment',
                        style: TextStyle(color: Color(0xff229546), fontWeight: FontWeight.bold),
                      ),
                      if(value_type=='NON_VALUABLE')

                      Text(
                        'Score: $result Exercise',
                        style: TextStyle(color: Color(0xff229546), fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Due Date: $deadline',
                        style: TextStyle(color: Colors.grey),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Posted $post',
                            style: TextStyle(color: Colors.grey),
                          ),

                        ],
                      ),
                      if(type=='DOWNLOADABLE_ASSIGNMENT')
                        Text(
                          'Downloadable Assignment',
                          style: TextStyle(color: Color(0xff3c8dcb)),
                        ),
                      if(type=='ONLINE_ASSIGNMENT')
                        Text(
                          'Online Assignment',
                          style: TextStyle(color: Color(0xff229546)),
                        ),




                    ],
                  )

            ),
          ),
        ),
      ),
    );
    else{
      return Container();
    }
//===================================================================
  }

  Widget getBodyNotGraded() {
    if (users.contains(null) || users.length < 0 || isLoading) {
      return Center(
          child: const SpinKitDoubleBounce(size: 71.0, color: Color(0xff229546)));
    }
    if (socketException || timeoutException) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/animation.png'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: Icon(
                        Icons.sync,
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
                )
              ],
            ),
          ));
    }

    if(uploadLoading){
      return Material(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Uploading '),
              SpinKitThreeBounce(
                color: Color(0xff229546),
                size: 30,
              ),
            ],
          ));
    }
    if(users.length==0) {
      return Center(
        child: SingleChildScrollView(
          child: Container(
            width: 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 300,
                  child: Image(image: AssetImage('assets/Nocontant.png'),),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return downloading
        ? Center(
      child: Container(
        height: 120.0,
        width: 200.0,
        child: Card(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:  CrossAxisAlignment.center,
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
      ),
    )
        : SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return getNotGraded(users[index]);
              }),
        ],
      ),
    );
  }

  Widget getNotGraded(item) {
    var name = item['as_title'];

    var type = item['as_type'];
    //==================================
    var post = item['posted'];
    var deadline = item['deadline'];
    var value_type = item['value_type'];

if(item['score_status']=='Not Graded')
    return InkWell(
      onTap: () {

        if(item['as_type']!='ONLINE_ASSIGNMENT')
        {
          print(item['id']);
          showDialog(
            context: this.context,
            builder: (BuildContext context ) => _buildrequestPopupDialog(context,  item['as_title'], item['as_loc'], item['id'],item['as_status'], item['submission_status'], item['score_status'], item['score']),
          );
          final mimeType = lookupMimeType(item['as_loc']);
          print(mimeType);
          if (mimeType == 'image/png' ||
              mimeType == 'image/jpeg' ||
              mimeType == 'image/jpg ') {
            print(mimeType);
            print(item['as_loc']);
          }
        }
        else{
          print(item['id']);
          showDialog(
            context: this.context,
            builder: (BuildContext context ) => _buildonlineexamPopupDialog(context,item['id'], item['as_title'], item['value'],item['posted'], item['deadline'],  item['as_status'], item['take_status'], item['value_type'], item['score_status'], item['score']),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Card(
          elevation: 3,
          shadowColor: Color(0x502196F3),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
            child: ListTile(
                leading: Icon(Icons.library_books, color:
                type=='DOWNLOADABLE_ASSIGNMENT'? Color(0xff3c8dcb): Color(0xff229546)),
                title:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(this.context).size.width - 140,
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: name,
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
                    if(value_type=='VALUABLE')
                      Text(
                        'Value:${item['value']}  Assessment',
                        style: TextStyle(color: Color(0xff229546)),
                      ),
                    if(value_type=='NON_VALUABLE')
                      Text(
                        'Value:${item['value']}  Exercise',
                        style: TextStyle(color: Color(0xff229546)),
                      ),
                    Text(
                      'Due Date: $deadline',
                      style: TextStyle(color: Colors.grey),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Posted $post',
                          style: TextStyle(color: Colors.grey),
                        ),

                      ],
                    ),
                    if(type=='DOWNLOADABLE_ASSIGNMENT')
                      Text(
                        'Downloadable  Assignment',
                        style: TextStyle(color: Color(0xff3c8dcb), fontWeight: FontWeight.bold),
                      ),
                    if(type=='ONLINE_ASSIGNMENT')
                      Text(
                        'Online Assignment',
                        style: TextStyle(color: Color(0xff229546), fontWeight: FontWeight.bold),
                      ),



                  ],
                )

            ),
          ),
        ),
      ),
    );
else{
  return Container();
}
//===================================================================
  }


  Widget _buildrequestPopupDialog(BuildContext context,title, path, id , as_status, submission_status, score_status, score) {
    return new AlertDialog(
      title: const Text('', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 2)),

      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [



            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  final mimeType = lookupMimeType(path);
                  print(mimeType);
                  if(mimeType=='image/png' || mimeType=='image/jpeg' || mimeType=='image/jpg'){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => new ImageViewer(title: title,
                            link: httpUrl+path)));
                  }
                  else if(mimeType=='application/pdf')
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new pdftest(
                                title: title,
                                link: path)));
                  }
                  else
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new WebViewPage(
                                title: title,
                                link: "http://view.officeapps.live.com/op/view.aspx?src=$httpUrl" + path)));
                  }
                },
                    child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grid_view, color: Color(0xff229546),),
                            Text(
                              '  View',  style: GoogleFonts.roboto(
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
                  Navigator.of(context).pop();
                  downloadFile(title,path);
                },
                child: Align(
                  alignment: Alignment.center,

                      child: Center(
                        child: Align(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                             Icon(Icons.download_sharp, color: Color(0xff229546),),
                              Text(
                                '  Download File',  style: GoogleFonts.roboto(
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
            if(submission_status=="Not Submitted" && as_status=="Open")
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: this.context,
                    builder: (BuildContext context ) => _fileChoose(context, id, title),
                  );
                },
                child: Align(
                  alignment: Alignment.center,

                  child: Center(
                    child: Align(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_rounded, color: Color(0xff229546),),
                          Text(
                            '  Upload Solution',  style: GoogleFonts.roboto(
                            textStyle: TextStyle(color: Color(0xff000000), fontSize: 20, shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.5, 1.5),
                                blurRadius: 3.0,
                                color: Color(0x2D7BA0E0),
                              ),
                            ],fontWeight: FontWeight.bold),),),
                        ],),),),),),),
            if(submission_status=="Submitted")
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    if(as_status=="Closed" || score_status=='Graded') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => new SubmissionAnswer(
                                  Assignment_id: id,
                                  Assignment_name: title,
                                  Assignment_status: 'taken')));
                    }
                    else{
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => new SubmissionAnswer(
                                  Assignment_id: id,
                                  Assignment_name: title,
                              )));
                    }
                  },
                  child: Align(
                    alignment: Alignment.center,

                    child: Center(
                      child: Align(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_rounded, color: Color(0xff229546),),
                            Text(
                              '  Your Solution',  style: GoogleFonts.roboto(
                              textStyle: TextStyle(color: Color(0xff000000), fontSize: 20, shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(1.5, 1.5),
                                  blurRadius: 3.0,
                                  color: Color(0x2D7BA0E0),
                                ),
                              ],fontWeight: FontWeight.bold),),),
                          ],),),),),),),
            if(submission_status=="Not Submitted" && as_status=="Open")
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Divider(color: Color(0xff229546)),
            ),
            if(submission_status=="Submitted")
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Divider(color: Color(0xff229546)),
              ),
            if(score_status!='Graded' && submission_status!="Submitted" && as_status=="Closed")
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(

                    decoration: BoxDecoration(
                      color: Color(0x8f229546),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          ' Exam Missed!',
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
                          )),
                    ),
                  ),
                ),
              ),
            if(score_status=='Graded')
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(

                    decoration: BoxDecoration(
                      color: Color(0x8f229546),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          ' Score: $score',
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
                          )),
                    ),
                  ),
                ),
              ),
            if(score_status!='Graded' && submission_status=="Submitted")
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(

                    decoration: BoxDecoration(
                      color: Color(0x8f229546),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          'Solution Submitted!',
                          style: GoogleFonts.fredokaOne(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xffffffff),
                              letterSpacing: 2,
                              fontSize: 16,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                  color: Color(0x48000000),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
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

  Widget _fileChoose(BuildContext context, id, title) {
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
                  getImage(id, title);
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
                  filepick(id, title);
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


  Widget _buildonlineexamPopupDialog(BuildContext context,Exam_id, title, value,posted, closes, as_status, take_status,value_type, score_status, score) {
    return new AlertDialog(
      title: const Text('', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 2)),

      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Exam Title: $title',
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
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Total value: $value',
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
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Deadline: $closes',
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
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Posted: $posted',
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
            if(value_type=='VALUABLE')
            SizedBox(
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Continuous Assessment',
                        style: TextStyle(
                          color:Color(0xff229546),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                  ],
                ),
              ),
            ),
            if(value_type=='NON_VALUABLE')
              SizedBox(
                child: Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Exercise',
                          style: TextStyle(
                            color:Color(0xff229546),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                    ],
                  ),
                ),
              ),

            if(as_status=='Open' && take_status!='Taken'  )
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OnlineAssignment(
                              exam_id: Exam_id,
                              exam_name: title,
                              ends_at:closes,
                              exam_type:'Assignment'
                          ))).then((val) => val ? _getRequests() : null);
                },
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
                            'Start',  style: GoogleFonts.fredokaOne(
                            textStyle: TextStyle(color: Colors.white,letterSpacing: .5, fontSize: 20,),),),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if(score_status=="Graded")
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(

                    decoration: BoxDecoration(
                      color: Color(0x8f229546),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          ' score: $score',
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
                          )),
                    ),
                  ),
                ),
              ),
            if(score_status!='Graded' && take_status!="Taken" && as_status=="Closed")
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(

                    decoration: BoxDecoration(
                      color: Color(0x8f229546),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          ' Exam Missed!',
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
                          )),
                    ),
                  ),
                ),
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
