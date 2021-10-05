import 'dart:html';

export 'dart:html';



class ItemUrlPolicy implements UriPolicy {
  RegExp regex = RegExp(r'(?:http://|https://)?.*');

  @override
  bool allowsUri(String uri) {
    return regex.hasMatch(uri);
  }
}