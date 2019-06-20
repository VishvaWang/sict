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

enum loginPageState{inputing,logining,reinputing}

class LoginPageState extends State<LoginPage>{

  setDefault(){
    accountController.text='201608920132';
    passwordController.text='058154';
    return true;
  }
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  loginPageState currentLoginPageState = loginPageState.inputing;

  List<String> titles=['输入中 · · ·','登录中 · · ·','重新输入 · · ·'];
  bool pwdError;



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(titles[currentLoginPageState.index]),
      ),
      body:getBody()

    );
  }
  Widget getBody(){

    assert(setDefault());

    switch (currentLoginPageState){

      case loginPageState.inputing:
      case loginPageState.reinputing:

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
                    currentLoginPageState=loginPageState.logining;
                  });

                  if(await tryLogin()) {

                    HttpClientResponse response =await Sict.queryCourse();
                    String body=await response.transform(utf8.decoder).join();
                    String userInfo=(await Sict.getUser()).toString();
                    //todo 获取到的body即使是错误的也会存入本地缓存 缺少错误校验
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

                    setState((){
                      currentLoginPageState=loginPageState.reinputing;
                    });

                    MyHttp.emptyCookie();
                  }

                }
            )
            ,
          ],
        );

      case loginPageState.logining:
        return Center(heightFactor:9,child:CircularProgressIndicator(value: null,));
    }
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
    await Future.delayed(Duration(milliseconds: 500));
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

