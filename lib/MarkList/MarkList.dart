import 'dart:convert';

import 'package:abugida_online/utils/httpUrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
class MarkList extends StatefulWidget {
  final course_id;
  final course_name;

  MarkList({
    this.course_id,
    this.course_name,
  });
  @override
  _MarkListState createState() => _MarkListState();
}

class _MarkListState extends State<MarkList> {
 var marklistArray;
  bool isLoading = false;
  List ScoreList=[];
  List AssignmentList=[];
  @override
  void initState() {
    super.initState();
    this.fetchmark();
  }
  fetchmark() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var url = Uri.parse("$httpUrl/api/showCourseMarklist/${widget.course_id}");
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    print(response.body);
    if(response.statusCode == 200){
      var items = json.decode(response.body);
      print(items);
      setState(() {
        marklistArray = items;
        isLoading = false;
        ScoreList=marklistArray['scores'];
        print(ScoreList);
        AssignmentList=marklistArray['assessments'];
        print(marklistArray['scores']);
      });
    }else{

      isLoading = false;
    }
  }
  Material myItems3(){
    return Material(

        color: Colors.white,
        elevation: 14,
        shadowColor: Color(0x802196F3),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.0),
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0)),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(

                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width*0.3,
                        child: Text('Items',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    Padding(

                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width*0.2,
                        child: Text('Value',
                          style: TextStyle(
                              color: Colors.black,fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    Padding(

                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width*0.15,
                        child: Text('Score',
                          style: TextStyle(
                              color: Colors.black,fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Divider(
                      color: Colors.black
                  ),
                )
              ],
            ),
            for (var i = 0; i < AssignmentList.length; i++)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(

                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width*0.3,
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: '${i + 1}. ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                                TextSpan(
                                    text: '${AssignmentList[i]["as_title"]}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),

                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(

                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width*0.2,
                          child: Text('${AssignmentList[i]["value"]}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16
                            ),
                          ),
                        ),
                      ),
                      if(ScoreList[i]["score"]!='')
                      Padding(

                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width*0.15,
                          child: Text('${ScoreList[i]["score"]}',
                             style: TextStyle(
                                color: Colors.black,
                                fontSize: 16
                            ),
                          ),
                        ),
                      ),
                      if(ScoreList[i]["score"]=='')
                        Padding(

                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width*0.15,
                            child: Text('-',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Divider(
                        color: Colors.black
                    ),
                  )

                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(

                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.3,
                    child: Text('Total',
                      style: TextStyle(
                          color: Colors.black,fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                  ),
                ),
                Padding(

                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: Text('${marklistArray['value_total']}',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if(marklistArray['score_total']!=null)
                  Padding(

                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.15,
                      child: Text('${marklistArray['score_total']}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if(marklistArray['score_total']==null)
                  Padding(

                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.15,
                      child: Text('-',
                        style: TextStyle(
                            color: Colors.black,fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            //--------------------- Print button -----------------------------------------------


          ],
        )



    );
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          appBar: new AppBar(
            elevation: 0.1,
            title: Text('Marklist'),
          ),
          body: Center(
            child: SpinKitDoubleBounce(
              color: Color(0xff229546),
              size: 71,
            ),
          ));}
    return Scaffold(

      appBar: new AppBar(
        elevation: 0.1,
        title: Text('Marklist'),
      ),
      body: StaggeredGridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        physics: ScrollPhysics(),
        children: <Widget>[

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading ? Center(child: CircularProgressIndicator()) :
                myItems3(),

          ),

        ],
        staggeredTiles: [

          StaggeredTile.fit(4)


        ],
      ),
    );
  }
}
