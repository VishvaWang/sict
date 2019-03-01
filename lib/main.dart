import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sict/page/CourseTablePage.dart';
import 'package:sict/page/LoginPage.dart';
import 'package:sict/tools/Info.dart';



 main(){
   Info.init();
   runApp(new SICT());
}
class SICT extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '商院',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: init(context),
    );
  }
}
init(context){
  if(Info.firstLaunch==null?!File(Info.filePath).existsSync():Info.firstLaunch) {//未初始化完成则同步判断是否存在
    return  LoginPage();
  }else {
    return  CourseTablePage();
  }
}