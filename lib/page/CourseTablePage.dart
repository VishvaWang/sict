
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sict/entity/Course.dart';
import 'package:sict/page/LoginPage.dart';
import 'package:sict/page/Scorepage.dart';
import 'package:sict/tools/Info.dart';
import 'package:sict/tools/Sict.dart';

class CourseTablePage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the Drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text(Info.get('userInfo')),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('课程'),
                onTap: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute(
                      builder: (context)
                      =>CourseTablePage(),
                    ),
                  );
                },
              ),ListTile(
                title: Text('成绩'),
                onTap: () async {
                  String scoreBody;
                  if(Info.get('scoreBody')==null) {
                    scoreBody = await
                    (await Sict.queryScore()).transform(utf8.decoder).join();
                    Info.set('scoreBody',scoreBody);
                  }else{
                    scoreBody=Info.get('scoreBody');
                  }
                  String tbody=RegExp(r'<tbody (?:.*?)>((.|\r|\n)*)</tbody>').firstMatch(scoreBody).group(1);
                  List<String>trs=RegExp(r'<tr.*?>((.|\r|\n)*?)</tr>').allMatches(tbody).map((m)=>m.group(1)).toList();
                  List<List<String>>tdsList=trs.map((tr)=>RegExp(r'<td.*?>((.|\r|\n)*?)</td>').allMatches(tr).map((m)=>m.group(1).trim()).toList()).toList();

                  Navigator.of(context).push(
                    new MaterialPageRoute(
                      builder: (context)
                      =>ScorePage(tdsList),
                    ),
                  );

                  Info.saveSync();
                },
              ),
              ListTile(
                title: Text('注销'),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    new MaterialPageRoute(
                      builder: (context)
                      =>LoginPage(),
                    ),
                  );
                  File(Info.filePath).deleteSync();
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('课程'),
        ),
        body: Container(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  getExpanded(1),
                  getExpanded(3),
                  getExpanded(5),
                  getExpanded(7),
                  getExpanded(9),
                  Text('星期六'+lessons.where((c)=>c.weekday==6).toList()[0].toString())
                ],),
        ),
    );
  }
}
List<Course> lessons= Course.creatList(Info.get(Sict.thisWeek().toString()));
getExpandeds(lesson){
  getExpanded(weekDay){

    List<Course> lessons= Course.creatList(Info.get(Sict.thisWeek().toString()))
        .where((f)=>f.startLesson==lesson)
        .toList();
    if(lessons.any((f)=>f.weekday==weekDay)) {
      var c=lessons.firstWhere((c)=>c.weekday==weekDay);
      return Expanded(flex: 1,child: Container(
        color: Colors.blueAccent,child: Text(
          c.toString()
      ),
      ),);
    }else{
      return Expanded(flex: 1,child: Container(
        child: Text(''),
      ),);
    }
  }
  List<Expanded> r=List();
  for(int i= 1;i<=5;i++) {
    r.add(getExpanded(i));
  }
  return r;
}
getExpanded(lesson){
  return Expanded(flex: 1,child:Row(children:getExpandeds(lesson),));
}
