import 'dart:async';
import 'dart:io';

void main() async {

  var i = 0;
  while (i < 150) {
    start();
    i++;
  }


}



start()async{
  var st = Stopwatch()..start();
  var i = 0;
  var s = 0;
  var c = Completer();
  try {
    var cl = HttpClient();
    while (i < 150) {
      var l = i == 149;
      await Future.delayed(Duration(milliseconds: 10));
      cl.getUrl(Uri.parse("http://localhost/any_ex")).then((req) {
        req.close().then((res) {
          s++;
          if (l) {
            c.complete();
          }
        });
      });
      i++;
    }
  } on Exception {
    print("$s in ${st.elapsedMilliseconds} ms");
  }
  await c.future;
  print("$s in ${st.elapsedMilliseconds} ms");
  st.stop();
}