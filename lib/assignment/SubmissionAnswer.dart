import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abugida_online/ImageViewer/ImageViewer.dart';
import 'package:abugida_online/assignment/assignment.dart';
import 'package:abugida_online/main.dart';
import 'package:abugida_online/pdftest.dart';
import 'package:abugida_online/resources/Resources.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:abugida_online/webview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:async/async.dart';
import 'package:path/path.dart';

//================================================================================

class SubmissionAnswer extends StatefulWidget {
  final Assignment_id;
  final Assignment_name;
  final Assignment_status;

  SubmissionAnswer({
    this.Assignment_id,
    this.Assignment_name,
    this.Assignment_status
  });
  @override
  _SubmissionAnswerState createState() => _SubmissionAnswerState();
}

class _SubmissionAnswerState extends State<SubmissionAnswer> {
  _getRequests() async {
    setState(() {
      Navigator.of(this.context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(loginVerified: true)),
              (Route<dynamic> route) => false);
    });
  }

  List solution = [];
  var SubmitionId;
  List BalanceArray = [];
  bool isLoading = false;
  bool uploadLoading = false;
  bool timeoutException = false;
  bool socketException = false;
  bool catchException = false;
  double Balance = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.openAssignments();
  }
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
    request.fields['as_id'] = '${widget.Assignment_id}';
    // multipart that takes file
    var multipartFile = new http.MultipartFile('sol_file', stream, length,
        filename: basename(filePath.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    await request.send().then((response) async {
      // listen for response
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });

    }).catchError((e) {
      print(e);
    });
    setState(() {
      uploadLoading = false;
    });
    refreshList();
  }

  openAssignments() async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url = Uri.parse("$httpUrl/api/openAssignments/${widget.Assignment_id}");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          SubmitionId= items['submission_id'];
          isLoading = false;
          MySubmission(SubmitionId);
        });
      } else {
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
  MySubmission( id) async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url = Uri.parse("$httpUrl/api/getMySubmission/${id}");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          solution = items['solutions'];
          isLoading = false;
        });
      } else {
        solution = [];
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
  Delete(submissionId, index) async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      var url = Uri.parse("$httpUrl/api/removeSolution/$submissionId/$index");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {

        var jsonResponse = json.decode(response.body);
        print("${response.statusCode}");
        print("${response.body}");
        Fluttertoast.showToast(
            msg: "Solution deleted",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);

        refreshList();
        print(response.body);
      }
      if (response.statusCode == 422) {
        Fluttertoast.showToast(
            msg: "Agent has balance and cannot be deleted!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
        Navigator.pop(this.context, true);
        setState(() {
          isLoading = false;
        });
        print(response.body);
      } else {
        setState(() {
          isLoading = false;
        });
        print(response.body);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      setState(() {
        isLoading = false;
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
      openAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
        onRefresh: refreshList,
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.Assignment_name} Solution'),
          ),
          body: socketException || timeoutException
              ? NoConnectionBody()
              : getBody(),
          floatingActionButton:widget.Assignment_status!='taken'?
          FloatingActionButton.extended(
            onPressed: (){
            showDialog(
              context: this.context,
              builder: (BuildContext context ) => _fileChoose(context, widget.Assignment_id),
            );},
            tooltip: 'Increment',
            label: const Text('Add Solution'),
            icon: const Icon(Icons.upload_file),

          ):Container()));
  }

  Widget getBody() {
    if (solution.contains(null) || solution.length < 0 || isLoading) {
      return Material(
          child: SpinKitDoubleBounce(
            color: Color(0xff229546),
            size: 71,
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
    return SingleChildScrollView(
      child: Column(

        children: [

          ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: solution.length,
              itemBuilder: (context, index) {
                return getCard(solution[index], index);
              }),
        ],
      ),

    );
  }
  Widget getCard(item, index) {



    //=====================================

    return InkWell(
      onTap: () {
        showDialog(
          context: this.context,
          builder: (BuildContext context) => _buildPopupDialog(context, index),

        );
      },
      child: Card(
        elevation: 3,
        shadowColor: Color(0x502196F3),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'page ${index+1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )),
                            ],
                          ),
                        ),

                        VerticalDivider(  color: Colors.grey,
                            thickness: 1,
                            indent: 20,
                            endIndent: 0,
                            width: 20,),

                        new FlatButton(onPressed: (){
                          Navigator.of(this.context).pop();
                          final mimeType = lookupMimeType(item['link']);
                          print(mimeType);
                          if(mimeType=='image/png' || mimeType=='image/jpeg' || mimeType=='image/jpg'){
                            Navigator.push(this.context,
                                MaterialPageRoute(builder: (context) => new ImageViewer(title: 'page ${index+1}',
                                    link: httpUrl+item['link'])));
                          }
                          else if(mimeType=='application/pdf')
                          {
                            Navigator.push(
                                this.context,
                                MaterialPageRoute(
                                    builder: (context) => new pdftest(
                                        title: 'page ${index+1}',
                                        link: item['link'])));
                          }
                          else
                          {
                            Navigator.push(
                                this.context,
                                MaterialPageRoute(
                                    builder: (context) => new WebViewPage(
                                        title: 'page ${index+1}',
                                        link: "http://view.officeapps.live.com/op/view.aspx?src=$httpUrl" + item['link'])));
                          }
                        }, child: Row(children: <Widget>[
                          new Icon(Icons.grid_view, color: Color(0xff82C042)),
                          new Text(' View',style: TextStyle(color: Color(0xff82C042), ),  ),
                        ],)),

                        new FlatButton(onPressed: () {
                          Delete(SubmitionId, item['id']);
                        }, child: Row(children: <Widget>[
                          new Icon(Icons.delete_forever, color: Colors.red, ),
                          new Text(' delete',style: TextStyle(color: Colors.red, ), ),
                        ],)),
                      ],
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

        ],
      ),
    );
  }
  Widget _buildPopupDialog(BuildContext context,index) {
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
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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
