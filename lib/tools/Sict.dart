import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sict/page/LoginPage.dart';
import 'package:sict/tools/Info.dart';
import 'package:sict/tools/MyHttp.dart';
import 'package:sict/entity/User.dart';

class Sict {
  static login(String account ,String password) async {

    HttpClientResponse response=await Sict.post('login.action');

    if(response.headers.value('set-cookie')!=null) {
      MyHttp.cookie =response.headers.value('set-cookie');
    }

    if(response.statusCode==302){
      return true;
    }

    var html=await response.transform(utf8.decoder).join();
    var index=html.indexOf("CryptoJS.SHA1('")+"CryptoJS.SHA1('".length;
    var sha1String = html.substring(index,index+37);
    var bytes = utf8.encode(sha1String+password);

    sleep(new Duration(milliseconds: 500));

    response=await  Sict.post(
        'login.action',
        'username=${account}&password=${sha1.convert(bytes).toString()}&encodedPassword=&session_locale=zh_CN'
    );

    if(response.statusCode==302) {
      return true;
    }else {
      String messageLine=await response
          .transform(utf8.decoder) //解码字节流
          .transform(new LineSplitter()).elementAt(62);
      String message=RegExp(r'>(.*?)<').firstMatch(messageLine).group(1);
    }
    return false;
  }

  static loginByCache(){
    return login(Info.get('account'), Info.get('password'));
  }

  static Future refreshCourse() async {
    if(await loginByCache()) {
      HttpClientResponse response =await Sict.queryCourse();
      String body=await response.transform(utf8.decoder).join();
      Info.set('${Sict.thisWeek()}', body);
      Info.saveSync();
      return true;
    }else {
      MyHttp.emptyCookie();
      return false;
    }
  }

  static  Future<HttpClientResponse> queryScore(){
     return  Sict.get('/teach/grade/course/person!search.action','semesterId=60');
  }

  static Future<User> getUser() async {
    User user=User();

//    (await getLines('stdDetail.action'))
////      ..elementAt(109).then((line)=>user.name=getText(line))
////      ..elementAt(136).then((line)=>user.faculty=getText(line))
////      ..elementAt(140).then((line)=>user.major=getText(line))
////      ..elementAt(148).then((line)=>user.entranceTime=getText(line))
////      ..elementAt(150).then((line)=>user.graduationTime=getText(line))
////      ..elementAt(168).then((line)=>user.classeAndGrade=getText(line));
////
    List<String> lines =await (await getLines('stdDetail.action')).toList();

    getText(line)=>RegExp(r'>(.*?)<').firstMatch(line).group(1);
    user.account=getText(lines[107]);
    user.name=getText(lines[109]);
    user.faculty=getText(lines[136]);
    user.major=getText(lines[140]);
    user.entranceTime=getText(lines[148]);
    user.graduationTime=getText(lines[150]);
    user.classeAndGrade=getText(lines[168]);

    return user;
  }

  static Future<HttpClientResponse> queryCourse() async {

    String idsLine = await (await Sict.getLines('courseTableForStd.action'))
                              .elementAt(146);
    String ids=  RegExp(r'[0-9]+').stringMatch(idsLine);
    Info.set('ids', ids);

    return await Sict.post(
        'courseTableForStd!courseTable.action',
        'ignoreHead=1&setting.kind=std&startWeek=${thisWeek()}&semester.id=${getSemesterId()}&ids=$ids'
    );

  }
  static int getSemesterId()=>82;

  static int thisWeek() {
    Duration difference = DateTime.now().difference(getSemesterStartDate());
    return difference.inDays~/7+1;
  }

  static DateTime getSemesterStartDate() => DateTime(2019,6,10);

  static Future<HttpClientResponse> post(String path,[data]) {
    Uri uri=Uri(scheme: "http",host: "szyjxgl.sict.edu.cn",port:9000,path:'eams/$path');
    return MyHttp.post(uri ,data);
  }

  static Future<HttpClientResponse> get(String path,String queryString) {
    Uri uri=Uri(scheme: "http",host: "szyjxgl.sict.edu.cn",port:9000,path:'eams/$path',query: queryString);
    return MyHttp.get(uri);
  }

  static Future<Stream<String>> getLines(String path,[data]) async {
    return (await Sict.post(path,data)).asBroadcastStream()
        .transform(utf8.decoder)
        .transform(LineSplitter());
  }

}