import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abugida_online/ImageViewer/ImageViewer.dart';
import 'package:abugida_online/utils/ObscuringTextEditingController.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:abugida_online/webview.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;




import 'dart:math';

import 'package:abugida_online/ImageViewer/ImageViewer.dart';
import 'package:abugida_online/pdftest.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:abugida_online/webview.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

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
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  _getRequests()async{
    setState(() {
      fetchBooks();
    });
  }
  List users = [];
  List Category = [];
  List userSearch =[];
  List user= [];
  var CategoryReturn;
  bool checkPermission1;
  bool isLoading = false;
  bool timeoutException =false;
  bool socketException = false;
  bool catchException = false;
  final TextEditingController titleController = new TextEditingController();
  bool downloading = false;
  var progress = "";
  var path = "No Data";
  static final Random random = Random();
  var _title;
  var _onPressed;

  @override
  void initState() {
    // TODO: implement initState
    titleController.addListener(_onTiptitleChanged);
    super.initState();
    this.fetchBooks();
    fetchCategory();
  }
  _onTiptitleChanged() {
    setState(() {
      _title = titleController.text;

    });
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
        dirloc = "storage/emulated/0/Resource/";
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
  Filter(title, category) async {
    setState(() {
      isLoading = true;
    });
    int timeout = 20;
    try {
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');
      var url =
      Uri.parse("$httpUrl/api/searchMyBooks");
      var response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {
        "book_title":"$title",
        "book_cat":"$category"
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        print("${response.statusCode}");
        print("${response.body}");
          var items = json.decode(response.body);
        users = items;
        userSearch = users;
          setState(() {
            isLoading = false;
          });
      } else {
        setState(() {
          isLoading = false;
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
  fetchCategory() async {
    setState(() {
      isLoading = true;
    });
    int timeout=20;
    try
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url = Uri.parse("$httpUrl/api/bookCategories");
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        setState(() {
          Category = items;
          isLoading = false;
        });
      }
      else {
        setState(() {
          Category = [];
          isLoading = false;
        });
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
  fetchBooks() async {
    setState(() {
      isLoading = true;
    });
    int timeout=20;
    try
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var url = Uri.parse("$httpUrl/api/getMyLibrary");

      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(Duration(seconds: timeout));
      print(response.body);
      if (response.statusCode == 200) {
        var items = json.decode(response.body);
        print(response.body);
        setState(() {
          users = items;
          userSearch = users;
          isLoading = false;
        });
      }
      else if(response.statusCode == 401){
        Fluttertoast.showToast(
            msg: "Your Account is Locked",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      }
      else {
        setState(() {
          userSearch = [];
          isLoading = false;
        });

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
  Future<Null> refreshList() async{
    await Future.delayed(Duration(seconds:2));
    setState(() {
      fetchBooks();
      _amountController..text = '';
      confirmPasswordController..text ='';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context ) => _buildfilterPopupDialog(context),
          );
    },
    child: const Icon(Icons.filter_alt_outlined),
    backgroundColor: Color(0xff229546),
    ),
      body: RefreshIndicator(
          onRefresh: refreshList,
          child: getBody()),
    );
  }
  Widget getBody(){
    if (users.contains(null) || users.length < 0 || isLoading) {
      return Center(
          child: const SpinKitDoubleBounce(size: 71.0, color: Color(0xff229546)));
    }
    if(socketException || timeoutException){
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
                      icon: Icon(Icons.sync_rounded, color: Colors.orange,size: 50,),
                      onPressed: () {
                        setState(() {
                          socketException=false;
                          timeoutException=false;
                        });
                        refreshList();
                      }),
                )
              ],
            ),
          )
      );
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
    return   Padding(
      padding: const EdgeInsets.all(10.0),
      child: StaggeredGridView.countBuilder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        crossAxisCount: 2,

        itemBuilder: (context, index) {
          return index == 0  ?_searchBar() : getCard(index-1);
        },
        staggeredTileBuilder: (int index) =>
            StaggeredTile.fit(2),
        itemCount: userSearch.length+1,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
    );
  }
  _searchBar(){
    return Padding(padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
            hintText: "search Book Title..."
        ),
        onChanged: (text){
          text = text.toLowerCase();
          setState(() {
            userSearch = users.where((note) {
              var noteTitle =note['book_title'].toLowerCase();
              return noteTitle.contains(text);
            }).toList();
          });
        },
      ),);
  }
  Widget getCard(index){
    var Name = userSearch[index]['book_title'];
    var category = userSearch[index]['category'];

    return InkWell(
      onTap: () {

        showDialog(
          context: context,
          builder: (BuildContext context ) => _buildrequestPopupDialog(context,  userSearch[index]['book_title'], userSearch[index]['book_loc']),
        );
      },
      child: Card(
        elevation: 3,
        shadowColor: Color(0x502196F3),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            leading: Icon(Icons.menu_book, color: Color(0xff229546)),
            title: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 3,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.65,
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Title: ' ,
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: .5,
                                fontSize: 16,
                              ),
                            )),
                            TextSpan(
                                text: Name,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: Color(0xff229546),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: .5,
                                    fontSize: 16,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width *0.65,
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Category: ' ,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: Colors.black,

                                    letterSpacing: .5,
                                    fontSize: 16,
                                  ),
                                )),
                            TextSpan(
                                text: category,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: Color(0xff229546),

                                    letterSpacing: .5,
                                    fontSize: 16,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  final TextEditingController _amountController = new TextEditingController();
  final TextEditingController confirmPasswordController = new ObscuringTextEditingController();
  Widget _buildPopupDialog(BuildContext context, var phone) {
    return new AlertDialog(
      title:  Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5,),
            child: Icon(Icons.transfer_within_a_station, color: Colors.lightGreen, size: 30,),
          ),
          Text('Transfer to $phone', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),

      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  cursorColor: Color(0xff82C042),
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff82C042)),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      hintText: "amount",
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
                        borderSide: BorderSide(color: Color(0xff82C042)),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff82C042)),
                        borderRadius: BorderRadius.circular(25),
                      ))
              ),
              SizedBox(height: 10.0),


            ],
          ),
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {

            Fluttertoast.showToast(
                msg: "transfer canceled",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1
            );
            Navigator.of(context).pop();
            _amountController..text = '';
            confirmPasswordController..text = '';
          },
          child: const Text('Cancel', style: TextStyle(color: Color(0xff82C042), fontWeight: FontWeight.bold),),
        ),
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildConfirmTransferPopupDialog(context,phone),
            );



          },
          child: const Text('Ok' , style: TextStyle(color: Color(0xff82C042), fontWeight: FontWeight.bold)),
        ),

      ],
    );
  }


  Widget _buildConfirmTransferPopupDialog(BuildContext context, phone) {
    return new AlertDialog(
      title: const Text('Transfer', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 19)),

      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        new Text('Transfer To: $phone'),
                        new Text('Transfer Amount: ${_amountController.text} Birr'),
                      ],
                    ))
            ),
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width-140,
                  child: Padding(

                      padding: const EdgeInsets.all(8.0),
                      child: new Text('To transfer please confirm password:')
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                    controller: confirmPasswordController,

                    cursorColor: Color(0xff82C042),
                    keyboardType: TextInputType.number,

                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(4),
                    ],
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff82C042)),
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
                          borderSide: BorderSide(color: Color(0xff82C042)),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff82C042)),
                          borderRadius: BorderRadius.circular(25),
                        ))
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {

            Navigator.of(context).pop();
            _amountController..text = '';
            confirmPasswordController..text = '';
          },
          child: const Text('Cancel', style: TextStyle(color: Color(0xff82C042), fontWeight: FontWeight.bold),),
        ),
        new FlatButton(
          onPressed: () async {
            Navigator.of(context).pop();

            setState(() {

              print(user[0]['Password']);
            });
            if(user[0]['Password']==confirmPasswordController.text){

            }
            else{

              Fluttertoast.showToast(
                  msg: "Wrong password",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1
              );
            }
            _amountController..text = '';
            confirmPasswordController..text ='';
          },
          child: const Text('Ok' , style: TextStyle(color: Color(0xff82C042), fontWeight: FontWeight.bold)),
        ),

      ],
    );
  }
  Widget _buildrequestPopupDialog(BuildContext context,title, path ) {
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
  Widget _buildfilterPopupDialog(BuildContext context ) {
    return new AlertDialog(
      title: const Text('', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 2)),

      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text.rich(TextSpan(
                children: <TextSpan>[
                  TextSpan(text:'  Title', style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5,
                      fontSize: 16,
                    ),
                  )),
                ],
              )),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 50,
              child: TextFormField(
                controller: titleController,

                cursorColor: Color(0xff82C042),
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff82C042)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "BookTitle",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: Colors.black38,
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
                ,
              ),
            ),
            SizedBox(
              height: 15,
            ),

               Text.rich(TextSpan(
                children: <TextSpan>[
                  TextSpan(text:'  Category', style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .5,
                  fontSize: 16,
                ),
              )),
                ],
              )),
            SizedBox(
              height: 5,
            ),

            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width*0.65,
                      decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 1.0, color: Color(0xff229546)),
                            left: BorderSide(width: 1.0, color: Color(0xff229546)),
                            right: BorderSide(width: 1.0, color: Color(0xff229546)),
                            bottom: BorderSide(width: 1.0, color: Color(0xff229546)),
                          ),

                          borderRadius: BorderRadius.circular(10)),
                      // dropdown below..
                      child: new DropdownButton(
                        items: Category.map((item) {
                          return new DropdownMenuItem(
                            child: new Text(item['category']),
                            value: item['id'].toString(),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          setState(() {
                            CategoryReturn = newVal;
                            print(CategoryReturn);
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context ) => _buildfilterPopupDialog(context),
                            );
                          });
                        },
                        value: CategoryReturn,

                      ),
                    ),


                ],
              ),
            SizedBox(
              height:15,
            ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 40.0,
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            margin: EdgeInsets.only(top: 15.0),
            child: RaisedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Filter(titleController.text, CategoryReturn);
              },
              elevation: 0.0,
              disabledColor: Color(0xff229546),
              disabledTextColor: Colors.white54,
              color: Color(0xff229546),
              child: Text("Filter", style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
          ),
        ],
      )


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
  Widget _buildfilter2PopupDialog(BuildContext context ) {
    return new AlertDialog(
      title: const Text('', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 2)),

      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text.rich(TextSpan(
                children: <TextSpan>[
                  TextSpan(text:'  Title', style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5,
                      fontSize: 16,
                    ),
                  )),
                ],
              )),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 50,
              child: TextFormField(
                controller: titleController,

                cursorColor: Color(0xff82C042),
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff82C042)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "BookTitle",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: Colors.black38,
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
                ,
              ),
            ),
            SizedBox(
              height: 15,
            ),

            Text.rich(TextSpan(
              children: <TextSpan>[
                TextSpan(text:'  Category', style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .5,
                    fontSize: 16,
                  ),
                )),
              ],
            )),
            SizedBox(
              height: 5,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width*0.65,
                  decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Color(0xff229546)),
                        left: BorderSide(width: 1.0, color: Color(0xff229546)),
                        right: BorderSide(width: 1.0, color: Color(0xff229546)),
                        bottom: BorderSide(width: 1.0, color: Color(0xff229546)),
                      ),

                      borderRadius: BorderRadius.circular(10)),
                  // dropdown below..
                  child: new DropdownButton(
                    items: Category.map((item) {
                      return new DropdownMenuItem(
                        child: new Text(item['category']),
                        value: item['id'].toString(),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      setState(() {
                        CategoryReturn = newVal;
                        print(CategoryReturn);
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context ) => _buildfilterPopupDialog(context),
                        );
                      });
                    },
                    value: CategoryReturn,

                  ),
                ),


              ],
            ),
            SizedBox(
              height:15,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 40.0,
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  margin: EdgeInsets.only(top: 15.0),
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Filter(titleController.text, CategoryReturn);
                    },
                    elevation: 0.0,
                    disabledColor: Color(0xff229546),
                    disabledTextColor: Colors.white54,
                    color: Color(0xff229546),
                    child: Text("Filter", style: TextStyle(color: Colors.white)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ],
            )


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

