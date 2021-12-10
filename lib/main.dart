import 'dart:convert';
import 'dart:io';

import 'package:abugida_online/AboutPage.dart';
import 'package:abugida_online/Dashboard.dart';
import 'package:abugida_online/Library.dart';
import 'package:abugida_online/Quiz/CourseExams.dart';
import 'package:abugida_online/Videos/CourseVideo.dart';
import 'package:abugida_online/database_helper.dart';
import 'package:abugida_online/download/DownloadFolderAppBar.dart';
import 'package:abugida_online/resetPassword/resetPassword.dart';
import 'package:abugida_online/MarkList/CourseMarkList.dart';
import 'package:abugida_online/HomePage.dart';
import 'package:abugida_online/MyCourses.dart';
import 'package:abugida_online/MyQuestions/AddQuestions.dart';
import 'package:abugida_online/MyQuestions/QuestionsList.dart';
import 'package:abugida_online/Notice/NoticeList.dart';
import 'package:abugida_online/assignment/CourseAssignment.dart';
import 'package:abugida_online/download/FileDownloading.dart';
import 'package:abugida_online/download/downloadFolder.dart';
import 'package:abugida_online/download/downloadList.dart';
import 'package:abugida_online/fileupload.dart';
import 'package:abugida_online/login.dart';
import 'package:abugida_online/resources/CourseResources.dart';
import 'package:abugida_online/utils/httpUrl.dart';
import 'package:abugida_online/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
void main() {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xff229546),
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Abugida",
      theme: ThemeData(
        // Define the default brightness and colors.
        primaryColor: Color(0xff229546),
        accentColor: Color(0xff229546),

        // Define the default font family.

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
class HomePage extends StatefulWidget {
  final loginVerified;
  HomePage({this.loginVerified});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _getRequests() async {
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(loginVerified: true)),
          (Route<dynamic> route) => false);
    });
  }

  bool _permission = false;
  var users;
  bool isLoading = false;
  var name;
  var LName;
  var email ='Student';
  var class_name;
  var id;
  var section_name;

  SharedPreferences sharedPreferences;
  @override
  void initState() {
    checkLoginStatus();
    super.initState();
    fetchUser();
    fatchEmail();

  }
  fatchEmail() async{
    setState(() {
      isLoading = true;
    });
    List<Map<String,dynamic>> queryRows =await VerificationDatabaseHelper.instance.queryOneRows(1);
    setState(() {
      email=queryRows[0]['email'];
      isLoading = false;
    });
  }
  fetchUser() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = Uri.parse("$httpUrl/api/getStudent");
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    print(response.body);
    print(response.statusCode);
    if(response.statusCode == 200){
      var items = json.decode(response.body);
      users=items;
      name = users['f_name'];
      LName=users['l_name'];
      section_name = users['section_name'];
      class_name=users['class_name'];

      await VerificationDatabaseHelper.instance.update({
        VerificationDatabaseHelper.columnId: 1,
        VerificationDatabaseHelper.columnName: name,
        VerificationDatabaseHelper.columnsection: section_name,
        VerificationDatabaseHelper.columnclass: class_name,
      });
      setState(() {

        name = users['f_name'];
        LName=users['l_name'];
        section_name = users['section_name'];
        class_name=users['class_name'];

        isLoading = false;
      });
    
    }else{
      print(response.body);
      users = [];
      isLoading = false;
    }
  }
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  int selectedPage = 0;

  final _pageOptions = [Dashboard(),DownloadFolder(), QuestionsList()];
  var _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          elevation: 2,
          backgroundColor: Color(0xff229546),
          shadowColor: Color(0x502196F3),
          title: Text('Abugida Online',
              style: TextStyle(
                  color: new Color(0xffffffff),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ),
        drawer: new Drawer(
          child: new ListView(children: <Widget>[
            //           header

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    new CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child:
                          Image.asset('assets/Trillium.jpg', fit: BoxFit.fill),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(name!=null)
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: SizedBox(
                              width: MediaQuery.of(this.context).size.width*0.45,
                              child: Text('$name $LName',
                                  style: TextStyle(
                                      color: new Color(0xff000000),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          if(name==null)
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text('$email',
                                style: TextStyle(
                                    color: new Color(0xff000000),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ),
                          if(class_name!=null)
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text('$class_name $section_name',
                                style: TextStyle(
                                    color: new Color(0xff000000),
                                    fontSize: 15,
                                )),
                          ),
                          if(class_name==null)
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text('class ...',
                                  style: TextStyle(
                                    color: new Color(0xff000000),
                                    fontSize: 18,
                                  )),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new HomePage()));
              },
              child: ListTile(
                title: Text('Dashboard'),
                leading: Icon(Icons.dashboard, color: Color(0xff229546)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new CourseResources()));
              },
              child: ListTile(
                title: Text('My Resource'),
                leading: Icon(Icons.menu_book, color: Color(0xff229546)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new CourseAssignment()));
              },
              child: ListTile(
                title: Text('My Assignments'),
                leading: Icon(Icons.border_color, color: Color(0xff229546)),
              ),
            ),

            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new CourseExams()));
              },
              child: ListTile(
                title: Text('My Exam'),
                leading:
                Icon(Icons.edit_road_sharp, color: Color(0xff229546)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new QuestionsList()));
              },
              child: ListTile(
                title: Text('My Questions'),
                leading: Icon(Icons.download_done_outlined,
                    color: Color(0xff229546)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => new AddQuestion()));
              },
              child: ListTile(
                title: Text('Ask a teacher'),
                leading: Icon(Icons.question_answer, color: Color(0xff229546)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new CourseVideo()));
              },
              child: ListTile(
                title: Text('Videos'),
                leading: Icon(Icons.video_collection_rounded,
                    color: Color(0xff229546)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new NoticeList()));
              },
              child: ListTile(
                title: Text('Notices'),
                leading:
                    Icon(Icons.notifications_active, color: Color(0xff229546)),
              ),
            ),

            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new CourseMarklist()));
              },
              child: ListTile(
                title: Text('Marklist'),
                leading:
                Icon(Icons.verified_user_sharp, color: Color(0xff229546)),
              ),
            ),

            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new Library()));
              },
              child: ListTile(
                title: Text('My Library'),
                leading:
                Icon(Icons.my_library_books_outlined, color: Color(0xff229546)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new DownloadFolderAppBar()));
              },
              child: ListTile(
                title: Text('Downloads'),
                leading:
                Icon(Icons.download_outlined, color: Color(0xff229546)),
              ),
            ),
            Divider(),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new NewPassword()));
              },
              child: ListTile(
                title: Text('Change password'),
                leading: Icon(Icons.vpn_key_outlined),
              ),
            ),
            InkWell(
              onTap: () {
              },
              child: ListTile(
                title: Text('About'),
                leading: Icon(Icons.help),
              ),
            ),
            InkWell(
              onTap: () async {
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
              },
              child: ListTile(
                title: Text('Logout'),
                leading: Icon(Icons.logout),
              ),
            ),
          ]),
        ),
        body: PageView(
          children: _pageOptions,
          onPageChanged: (index) {
            setState(() {
              selectedPage = index;
            });
          },
          controller: _pageController,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), title: Text('Dashboard')),
            BottomNavigationBarItem(
                icon: Icon(Icons.download_sharp), title: Text('Downloads')),
            BottomNavigationBarItem(
                icon: Icon(Icons.question_answer), title: Text('My Questions')),

          ],
          selectedItemColor: Color(0xff229546),
          elevation: 5.0,
          unselectedItemColor: Colors.black,
          currentIndex: selectedPage,
          backgroundColor: Colors.white,
          onTap: (index) {
            setState(() {
              selectedPage = index;
              _pageController.animateToPage(selectedPage,
                  duration: Duration(milliseconds: 200), curve: Curves.linear);
            });
          },
        ));
  }
}
