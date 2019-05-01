import 'dart:convert';
import 'dart:io';

import 'package:sict/page/LoginPage.dart';
import 'package:sict/tools/Info.dart';
import 'package:sict/tools/MyHttp.dart';
import 'package:sict/entity/User.dart';

class Sict {
  static refreshCourse() async {
    if(await LoginPageState().tryLogin()) {
      HttpClientResponse response =await Sict.queryCourse();
      String body=await response.transform(utf8.decoder).join();
      Info.set('${Sict.thisWeek()}', body);
    }else {
      MyHttp.emptyCookie();
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
  } static Future<HttpClientResponse> queryCourse() async {

    String idsLine = await (await Sict.getLines('courseTableForStd.action'))
                              .elementAt(146);
    String ids=  RegExp(r'[0-9]+').stringMatch(idsLine);
    Info.set('ids', ids);

    return await Sict.post('courseTableForStd!courseTable.action',
        'ignoreHead=1&setting.kind=std&startWeek=${thisWeek()}&semester.id=61&ids=$ids');
  }
  static int thisWeek() {
    Duration difference = DateTime.now().difference(DateTime(2019,2,18));
    return difference.inDays~/7+1;
  }
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