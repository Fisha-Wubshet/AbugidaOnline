import 'package:abugida_online/download/downloadFolder.dart';
import 'package:flutter/material.dart';
class DownloadFolderAppBar extends StatefulWidget {

  @override
  _DownloadFolderAppBarState createState() => _DownloadFolderAppBarState();
}

class _DownloadFolderAppBarState extends State<DownloadFolderAppBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
        elevation: 2,
        backgroundColor: Color(0xff229546),
    shadowColor: Color(0x502196F3),
    title: Text('Downloads',
    style: TextStyle(
    color: new Color(0xffffffff),
    fontSize: 20,
    fontWeight: FontWeight.bold)),),
      body: DownloadFolder(),
    );
  }
}
