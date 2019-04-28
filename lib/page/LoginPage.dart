import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sict/page/CourseTablePage.dart';
import 'package:sict/tools/Info.dart';
import 'package:sict/tools/MyHttp.dart';
import 'package:flutter_just_toast/flutter_just_toast.dart';
import 'package:sict/tools/Sict.dart';
class LoginPage extends StatefulWidget{
  @override
  State<LoginPage> createState() {
    return LoginPageState();
  }
}

enum state{inputing,logining,reinputing}

class LoginPageState extends State<LoginPage>{
  final TextEditingController accountController = TextEditingController(text:'201608920132');
  final TextEditingController passwordController = TextEditingController(text:'058154');
  state s = state.inputing;
  List<String> titles=['输入中 · · ·','登录中 · · ·','重新输入 · · ·'];
  bool pwdError;
  Widget getBody(){
    switch (s){
      case state.inputing:
      case state.reinputing:
        return Column(
          children: <Widget>[
            TextField(
              controller: accountController,
              autofocus: pwdError!=true,
              decoration: InputDecoration(
                  hintText: "学号",
                  prefixIcon: Icon(Icons.person)
              ),
            ),
            TextField(
              controller: passwordController,
              autofocus:pwdError==true,
              decoration: InputDecoration(
                  hintText: "密码",
                  prefixIcon: Icon(Icons.lock)
              ),
              obscureText: true,
            ),
            RaisedButton(
                child: Text("登录"),
                onPressed: () async {
                  setState(() {
                    s=state.logining;
                  });
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
                      MaterialPageRoute(
                        builder: (context)
                        =>CourseTablePage(),
                      ),
                    );
                    Info.saveSync();
                  }else {
                    setState(() {
                      s=state.reinputing;
                    });
                    MyHttp.emptyCookie();
                  }
                }
            )
            ,
          ],
        );
      case state.logining:
        return Center(heightFactor:9,child:CircularProgressIndicator(value: null,));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[s.index]),
      ),
      body:getBody()
    );
  }
  Future<bool> tryLogin() async {

    HttpClientResponse response=await Sict.post('login.action');
    if(response.headers.value('set-cookie')!=null) {
      MyHttp.cookie =response.headers.value('set-cookie');
    };
    if(response.statusCode==302)return true;
    var html=await response.transform(utf8.decoder).join();
    var index=html.indexOf("CryptoJS.SHA1('")+"CryptoJS.SHA1('".length;
    var sha1String = html.substring(index,index+37);
    var bytes = utf8.encode(sha1String+passwordController.text);
    sleep(new Duration(milliseconds: 500));
    response=await  Sict.post('login.action',
        'username=${accountController.text}&password=${sha1.convert(bytes).toString()}&encodedPassword=&session_locale=zh_CN');
    if(response.statusCode==302) {
      return true;
    }else {
      String messageLine=await response
          .transform(utf8.decoder) //解码字节流
          .transform(new LineSplitter()).elementAt(62);
      String message=RegExp(r'>(.*?)<').firstMatch(messageLine).group(1);
      pwdError=message=='密码错误';
      Toast.show(
          message:message,
          duration: Delay.SHORT,
          backgroundColor: Colors.blue,
          textColor: Colors.black);
    }
    return false;
  }
}

