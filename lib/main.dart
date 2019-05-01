import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sict/page/CourseTablePage.dart';
import 'package:sict/page/LoginPage.dart';
import 'package:sict/tools/Info.dart';

 main()  async {
   Info.init();
   runApp(MaterialApp(
     title: 'SICT',
     theme: ThemeData(
       primaryColor: Colors.white,
     ),
     home: init(),
   ));
}
Widget init()  {
  if(Info.firstLaunch==null?!File(Info.filePath).existsSync():Info.firstLaunch){//未初始化完成则同步判断文件是否存在
    return  LoginPage();
  }else {
    return  CourseTablePage();
  }
}