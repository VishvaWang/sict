import 'dart:convert';
import 'dart:io';
//自动存储有问题 todo
class Info {

  static const String dir='/data/user/0/Wang.Vishva.sict';
  static const String filePath='$dir/info.json';
  static Map info={};
  static Map writedInfo={};
  static bool firstLaunch;
  static init() async {

    firstLaunch=!await File(filePath).exists();
    if(!firstLaunch) info = json.decode(await File(filePath).readAsString());
  }
  static set(String key,value) async {
    info[key]=value;
    if(writedInfo!=info){
      await File(filePath).writeAsString(json.encode(info));
      writedInfo=info;
    }
  }
  static setMap(Map<String,dynamic> map) async {
    info.addAll(map);
    await File(filePath).writeAsString(json.encode(info));
    writedInfo=info;
  }
  static saveSync(){
    if(writedInfo!=info){
      File(filePath).writeAsStringSync(json.encode(info));
      writedInfo=info;
    }
  }
  static get(String key){
    if(info.containsKey(key)) {
      return info[key];
    }else {
      info = json.decode(File(filePath).readAsStringSync());
      return info[key];
    }
  }
}

