import 'package:flutter/material.dart';
class ScorePage extends StatelessWidget{
  List<List<String>> tdsList;


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('成绩'),
      ),
      body: ListView(
        children: creatTextEveryLine(),
      ),
    );
  }

  List<Widget>creatTextEveryLine(){
    return tdsList.map((tds){
String s=
''' 课程名称  ${tds[3]}
    平时成绩  ${tds[6]}
    期末成绩  ${tds[8]}
    最终成绩  ${tds[10]}
    ''';
      return Text(s);
    }).toList();
  }
  ScorePage(this.tdsList);
}
