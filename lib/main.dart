import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sict/page/CourseTablePage.dart';
import 'package:sict/page/LoginPage.dart';
import 'package:sict/tools/Info.dart';

 main(){
   Info.init();
   runApp(MaterialApp(
     title: 'SICT',
     theme: new ThemeData(
       primaryColor: Colors.white,
     ),
     home: init(),
   ));
}
init(){
  if(Info.firstLaunch==null?!File(Info.filePath).existsSync():Info.firstLaunch){//未初始化完成则同步判断文件是否存在
    return  LoginPage();
  }else {
    return  CourseTablePage();
  }
}