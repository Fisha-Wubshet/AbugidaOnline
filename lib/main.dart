import 'dart:io';

import 'package:abugida_online/Dashboard.dart';
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
import 'package:abugida_online/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isLoading = false;
  String name = 'Student';
  String town;
  int id;
  int phone;

  SharedPreferences sharedPreferences;
  @override
  void initState() {
    checkLoginStatus();
    super.initState();
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
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 14, bottom: 8),
              child: InkWell(
                onTap: () async {},
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
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
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('$name',
                              style: TextStyle(
                                  color: new Color(0xff000000),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
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
            Divider(),
            InkWell(
              onTap: () {},
              child: ListTile(
                title: Text('About'),
                leading: Icon(Icons.help),
              ),
            ),
            InkWell(
              onTap: () async {
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
