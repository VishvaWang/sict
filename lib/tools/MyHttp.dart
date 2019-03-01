import 'dart:convert';
import 'dart:io';
HttpClient httpClient = new HttpClient();
class MyHttp {
  static String cookie='';
  static Future<HttpClientResponse> post(Uri uri,[String data]) async {//data: 可选的 附加在请求体中的数据
    HttpClientRequest request= await httpClient.postUrl(uri);
    request.headers.add('cookie', cookie);

    if (data!=null){
      request.headers.add('Content-Type','application/x-www-form-urlencoded; charset=UTF-8');
      request.add(utf8.encode(data));
    }

    return request.close();
  }
  static Future<HttpClientResponse> get(Uri uri) async {//data: 可选的 附加在请求体中的数据
    HttpClientRequest request= await httpClient.getUrl(uri);
    request.headers.add('cookie', cookie);

    return request.close();
  }
  static emptyCookie() {
    cookie='';
  }
}


