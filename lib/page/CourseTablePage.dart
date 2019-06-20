
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sict/entity/Course.dart';
import 'package:sict/page/LoginPage.dart';
import 'package:sict/page/Scorepage.dart';
import 'package:sict/tools/Info.dart';
import 'package:sict/tools/Sict.dart';
import 'package:flutter_share_me/flutter_share_me.dart';

GlobalKey myKey ;
String body=Info.get(Sict.thisWeek().toString());
List<Course> courses=body==null?!null:Course.creatList(body);
ScrollController scrollController=ScrollController();

class CourseTablePage extends StatefulWidget{


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CourseTablePageState();
  }

}

class CourseTablePageState extends State{

  @override
  Widget build(BuildContext context) {
    myKey=GlobalKey();
    scrollController.addListener((){scrollController.jumpTo(0);});

    if (Info.get(Sict.thisWeek().toString())==null){
      Sict.refreshCourse().whenComplete(()=>setState((){}));
      return Center(heightFactor:9,child:CircularProgressIndicator(value: null,));
    }

    return Scaffold(
        drawer: Drawer(

          child: ListView(

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
                    MaterialPageRoute(
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
                    MaterialPageRoute(
                      builder: (context)
                      =>ScorePage(tdsList),
                    ),
                  );

                  Info.saveSync();
                },
              ),
              ListTile(
                title: Text('分享'),
                onTap: () {
                  FlutterShareMe().shareToSystem(
                      msg: '我超好用的,大家快来下载我吧');
                },
              ),
              ListTile(
                title: Text('注销'),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
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
          title: Text('课程 - 第${Sict.thisWeek()}周'),

        ),
        body:RefreshIndicator(
            child: SingleChildScrollView(
              key: myKey,
              controller:scrollController ,
              child: Flow(
                delegate: CourseFlowDelegate(),
                children:courses.map((e)=>Container(
                  margin:EdgeInsets.all(2),
                  padding: EdgeInsets.all(3),
                  child:Text(
                    e.toString(),
                    style: TextStyle(
//                      color: Colors.
                    ),
                  ),
                  decoration:BoxDecoration(
                      color: Colors.grey,
//                      color:Color(courses.indexOf(e)*1000000000),
                      borderRadius:BorderRadius.circular(10)
                  ),

                )).toList(),
              ),),
            onRefresh: () async {
              await Sict.refreshCourse();
              setState(() {
                courses=Course.creatList(Info.get(Sict.thisWeek().toString()));
              });

            })

    );
  }
}

class CourseFlowDelegate extends FlowDelegate{
  double width;
  double height;
  double childWidth;
  double childHeight;
  EdgeInsets margin;
  double blanking=25;
  @override
  Size getSize(BoxConstraints constraints) {

    var size=(myKey.currentContext.findRenderObject().constraints as BoxConstraints).biggest;
    width=size.width;
    height=size.height;
    margin=EdgeInsets.symmetric(horizontal: width*0.043,vertical: blanking/3);
    childWidth=(width-margin.left*2)/5;
    childHeight=(height-margin.top*2-blanking*2)/10;
    return Size(size.width,size.height+1);
  }

  @override
  void paintChildren(FlowPaintingContext context) {

    for (int i = 0; i < context.childCount; i++) {

      double x =margin.left+(courses[i].weekday-1)*childWidth;
      double y =margin.top+(courses[i].startLesson-1)*childHeight;
      if (courses[i].startLesson>4) y+=blanking;
      if (courses[i].startLesson>8) y+=blanking;
      context.paintChild(i, transform: Matrix4.translationValues(x, y, 0.0));
//      print(courses[i].name+'x坐标:$x y坐标:$y start:${courses[i].startLesson}');
      }
    }


  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
//    print(courses[i].name+' hegit:${height*(courses[i].endLesson-courses[i].startLesson+1)/2}');
    return BoxConstraints.expand(width: childWidth,height:childHeight*(courses[i].endLesson-courses[i].startLesson+1));
  }

  @override
  bool shouldRepaint(FlowDelegate oldDelegate) {
    return oldDelegate != this;
  }

}

Iterable<Container> Containers()sync*{
  for(int i=0;i<25;i++)yield Container(color:Color(i*20000000),);
}

