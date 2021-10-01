import 'dart:io';

void main() async {
  var i = 0;

  while (i < 50) {
    print("Başladı");
    var cl = HttpClient();
    var req = await cl.getUrl(Uri.parse("http://style:8080/lang"));
    print("İstek Gitti");
    var res = await req.close();
    print("Cevap Geldi");
    print(res.headers.host);
    i++;

    print("\n\n\n");
  }
}
