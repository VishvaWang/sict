
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sict/entity/Course.dart';
import 'package:sict/page/LoginPage.dart';
import 'package:sict/page/Scorepage.dart';
import 'package:sict/tools/Info.dart';
import 'package:sict/tools/Sict.dart';
GlobalKey myKey ;
String body=Info.get(Sict.thisWeek().toString());
List<Course> courses=body==null?!null:Course.creatList(body);
ScrollController scrollController=ScrollController();

class CourseTablePage extends StatelessWidget{
  refreshPage(BuildContext context) async {
    await Sict.refreshCourse();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context)=>CourseTablePage(),),
    );
  }
  @override
  Widget build(BuildContext context) {
    myKey=GlobalKey();
    scrollController.addListener((){scrollController.jumpTo(0);});
    if (Info.get(Sict.thisWeek().toString())==null){
      refreshPage(context);
      return Center(heightFactor:9,child:CircularProgressIndicator(value: null,));
    }
    courses =Course.creatList(Info.get(Sict.thisWeek().toString()));
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
//          centerTitle: true,
//          actions: <Widget>[ //导航栏右侧菜单
//            IconButton(
//                icon: Icon(Icons.refresh),
//                onPressed: () async {
//                  if(await LoginPageState().tryLogin()) {
//
//                    HttpClientResponse response =await Sict.queryCourse();
//                    String body=await response.transform(utf8.decoder).join();
//                    Info.set('${Sict.thisWeek()}', body);
//
//                    Navigator.of(context).pushReplacement(
//                      MaterialPageRoute(builder: (context)=>CourseTablePage(),),
//                    );
//                    Toast.show(message:'刷新成功');
//                  }else {
//                    MyHttp.emptyCookie();
//                  }
//                }
//            ),
//          ],
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
              refreshPage(context);
            })
//        GridView(
//          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//            crossAxisCount: 5, //横轴三个子widget
//            childAspectRatio: 0.703 //宽高比为1时，子widget
//          ),
//          children:Containers().toList(),
//       )
//          Container(
//              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                children: <Widget>[
//                  getExpanded(1),
//                  getExpanded(3),
//                  getExpanded(5),
//                  getExpanded(7),
//                  getExpanded(9),
//
////                  Text('星期六'+lessons.where((c)=>c.weekday==6).toList()[0].toString())
//                ],),
//        ),
    );
  }
//  Future<String> getCourseBody(BuildContext context) async {
//
//  }

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
//mergeCourse(){
//  courses.forEach((e){
//    courses.where((a){
//      return e.weekday==a.weekday&&
//        e.classRoom==a.classRoom&&
//        e.name==a.name&&
//        e.startLesson==a.
//    });
//  });
//}
Iterable<Container> Containers()sync*{
  for(int i=0;i<25;i++)yield Container(color:Color(i*20000000),);
}

//List<Course> lessons= Course.creatList(Info.get(Sict.thisWeek().toString())) ;
//getExpandeds(lesson){
//  getExpanded(weekDay){
//
//    List<Course> lessons= Course.creatList(Info.get(Sict.thisWeek().toString()))
//        .where((f)=>f.startLesson==lesson)
//        .toList();
//    if(lessons.any((f)=>f.weekday==weekDay)) {
//      var c=lessons.firstWhere((c)=>c.weekday==weekDay);
//      return Expanded(flex: 1,child: Container(
//        color: Colors.blueAccent,child: Text(
//          c.toString()
//      ),
//      ),);
//    }else{
//      return Expanded(flex: 1,child: Container(
//        child: Text(''),
//      ),);
//    }
//  }
//  List<Expanded> r=List();
//  for(int i= 1;i<=5;i++) {
//    r.add(getExpanded(i));
//  }
//  return r;
//}
//getExpanded(lesson){
//  return Expanded(flex: 1,child:Row(children:getExpandeds(lesson),));
//}
