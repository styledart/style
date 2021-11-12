
import 'package:style_dart/style_dart.dart';

///
class MyServer extends StatelessComponent {
  ///
  const MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(

        // Project root name for using in redirect
        // or reach microservices
        rootName: "example",

        // Root Endpoint handle http(s)://<host> requests
        // You can use redirect for your default endpoint
        // eg. Redirect("../index.html")
        // for redirecting documentation http://google.com
        // call http://localhost
        rootEndpoint: SimpleEndpoint.static("Hello World!"),

        // Data access for server default
        //
        // [SimpleDataAccess] create json file in this folder
        // for each collection and fetch changes.
        // [SimpleDataAccess] for only testing
        dataAccess: DataAccess(SimpleDataAccess(
            "D:/style/packages/style_cli/example/example/data/")),

        // you can change favicon.ico
        faviconDirectory: "D:/style/packages/style_cli/example/example/assets/",

        // Server routes
        children: [
          // This route allow any argument sub-routes (expect other routes)
          // as "name".
          //
          // Can reach the argument from any endpoint under this route
          //
          // This [SimpleEndpoint] endpoint create a document in
          // "greeters" collection with default [DataAccess].
          //
          // Call http(s)://<host>/<your_name> eg. http://localhost/jack
          Route("{name}", root: SimpleEndpoint((req, ctx) {
            DataAccess.of(ctx).create(Create(
                request: req,
                collection: "greeters",
                data: {"id": req.arguments["name"]}));
            return req.response("Greet from ${req.arguments["name"]}");
          })),

          // This route and endpoint return greeters collection
          // as json data with default [DataAccess]
          //
          // Call http://localhost/greeters
          Route("greeters", root: SimpleEndpoint((req, ctx) async {
            return req.response((await DataAccess.of(ctx)
                .readList(ReadMultiple(request: req, collection: "greeters"))));
          })),
        ]);
  }
}


