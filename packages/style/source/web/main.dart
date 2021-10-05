import 'my_core.dart';

Element? $(String value) {
  return querySelector(value);
}

void main() async {
  final _htmlValidator = NodeValidatorBuilder.common()
    ..allowHtml5(uriPolicy: ItemUrlPolicy())
    ..allowTemplating()
    ..allowImages(ItemUrlPolicy())
    ..allowCustomElement('<LINK>', uriPolicy: ItemUrlPolicy())
    ..allowCustomElement("<SCRIPT>", uriPolicy: ItemUrlPolicy())
    ..allowCustomElement("<SCRIPT defer=" ">", uriPolicy: ItemUrlPolicy())
    ..allowCustomElement('<META>', uriPolicy: ItemUrlPolicy())
    ..allowElement('<LINK>', uriPolicy: ItemUrlPolicy())
    ..allowElement("<SCRIPT>", uriPolicy: ItemUrlPolicy())
    ..allowElement("<SCRIPT defer=" ">", uriPolicy: ItemUrlPolicy())
    ..allowElement('<META>', uriPolicy: ItemUrlPolicy())
    ..allowCustomElement('link', uriPolicy: ItemUrlPolicy())
    ..allowCustomElement("script", uriPolicy: ItemUrlPolicy())
    ..allowCustomElement('meta', uriPolicy: ItemUrlPolicy())
    ..allowElement('link',
        uriPolicy: ItemUrlPolicy(), attributes: ["href", "rel"])
    ..allowElement("meta", uriPolicy: ItemUrlPolicy())
    ..allowElement('script',
        uriPolicy: ItemUrlPolicy(),
        attributes: ["src", "defer src", "type", "async"]);
  document.cookie = "MY:DART";

  var q = querySelector('#btn');

  print(q);

  $("#name")
      ?.append(document.createElement("h1")..text = document.cookie ?? "not");

  var doc = document.body?.querySelector("#clm");
  doc?.setInnerHtml("", validator: _htmlValidator);

  q?.onClick.listen((event) async {
    try {
      HttpRequest.getString("other_page/component.html?name=Veli")
          .then((resp) async {
        print("RES: $resp : : $doc");
        doc?.appendHtml(resp, validator: _htmlValidator);
        print("ATT: ${doc?.attributes}");

        var elem = ScriptElement()
          ..async = true
          ..defer = true
          ..src = "other_page/other.js"
          ..type = "application/javascript";

        document.body?.append(elem);
      });
    } on Exception catch (e, s) {
      print(e);
      print(s);
    }
  });
}
