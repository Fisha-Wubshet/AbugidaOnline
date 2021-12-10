import 'package:flutter/material.dart';
class AboutPage extends StatefulWidget {

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        elevation: 2,
        backgroundColor: Color(0xff229546),
        shadowColor: Color(0x502196F3),
        title: Text('About',
            style: TextStyle(
                color: new Color(0xffffffff),
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 300,
                    child: Image(image: AssetImage('assets/emptydata.png'),),
                  ),
            ),
          ),
        ),
      ));
  }
}
