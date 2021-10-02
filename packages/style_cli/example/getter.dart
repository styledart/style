import 'dart:io';

void main() async {
  var i = 0;

  while (i < 50) {
    print("Başladı");
    var cl = HttpClient();
     cl.getUrl(Uri.parse("http://localhost:8080/un-auth")).then((req) {
       print("İstek Gitti");
       req.close().then((res) {
         print("Cevap Geldi");
         print(res.statusCode);
       });
    });
    i++;
  }
}
