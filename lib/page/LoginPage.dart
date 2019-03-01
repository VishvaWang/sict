import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sict/page/CourseTablePage.dart';
import 'package:sict/tools/Info.dart';
import 'package:sict/tools/MyHttp.dart';
import 'package:flutter_just_toast/flutter_just_toast.dart';
import 'package:sict/tools/Sict.dart';
class LoginPage extends StatelessWidget{
  final TextEditingController accountController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    accountController.text='201608920132';
    passwordController.text='058154';
    return new Scaffold(
      appBar: new AppBar(
        title: Text('登录'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: accountController,
            autofocus: true,
            decoration: InputDecoration(
                hintText: "学号",
                prefixIcon: Icon(Icons.person)
            ),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
                hintText: "密码",
                prefixIcon: Icon(Icons.lock)
            ),
            obscureText: true,
          ),
          RaisedButton(
              child: Text("登录"),
              onPressed: () async {
                if(await tryLogin()) {
                  HttpClientResponse response =await Sict.queryCourse();
                  String body=await response.transform(utf8.decoder).join();
                  String userInfo=(await Sict.getUser()).toString();
                  Info.setMap({
                    'account':accountController.text,
                    'password':passwordController.text,
                    'cookie':MyHttp.cookie,
                    '${Sict.thisWeek()}':body,
                    'userInfo':userInfo
                  });

                  Navigator.of(context).pushReplacement(
                    new MaterialPageRoute(
                      builder: (context)
                       =>CourseTablePage(),
                    ),
                  );
                  Info.saveSync();
                }else {
                  MyHttp.emptyCookie();
                }
              }
          ),
        ],
      ),
    );
  }
  Future<bool> tryLogin() async {

    HttpClientResponse response=await Sict.post('login.action');
    if(response.headers.value('set-cookie')!=null) {
      MyHttp.cookie =response.headers.value('set-cookie');
    };
    var html=await response.transform(utf8.decoder).join();
    var index=html.indexOf("CryptoJS.SHA1('")+"CryptoJS.SHA1('".length;
    var sha1String = html.substring(index,index+37);
    var bytes = utf8.encode(sha1String+passwordController.text);
    sleep(new Duration(milliseconds: 400));
    response=await  Sict.post('login.action',
          'username=${accountController.text}&password=${sha1.convert(bytes).toString()}&encodedPassword=&session_locale=zh_CN');

    String message;

    if(response.statusCode==302) {
     message='登录成功';
    }else {
      String messageLine=await response
          .transform(utf8.decoder) //解码字节流
          .transform(new LineSplitter()).elementAt(62);
      message= RegExp(r'>(.*?)<').firstMatch(messageLine).group(1);

    }
    Toast.show(message:"$message",duration: Delay.SHORT,
      backgroundColor: Colors.blue,
      textColor: Colors.black);

    return response.statusCode==302;
  }
}
