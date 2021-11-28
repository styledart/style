# style_dart

Style dart is a backend framework written in Flutter coding style.

[Join Discord Community](https://discord.gg/bPcscvBM)

You can see our main motivation, purpose and what it looks like in general with this article. Documentation and website
will be developed soon.

# Get Started

### 1 ) Create a dart simple-command-line application

### 2 ) Add dependency

``  style_dart: latest``

## 3 ) Create a server

Similar to Flutter, "everything is a component" structure used in Style.

The `runService(MyComponent())` method runs a style application.

### Define a Component

There is a component to create a simple server : ``Server``

It is the equivalent of "MaterialApp" or "CupertinoApp" in Flutter.

`Server` is a `ServiceOwner`. `ServiceOwner` holds states, cron jobs and component tree.

Not Implemented yet but components such as `MicroService` and `ServiceServer`(It will be used to share services such as
Logger between Servers/Microservices.) are `ServiceOwner`.

`Server` receive and hold main gateway(`children`) , default services(like `httpService`) , root
endpoint (`rootEndpoint`) , exception endpoints and etc.

Now let's create a simple http server:

```dart
class MyServer extends StatelessComponent {
  const MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(

      /// default localhost:80
        httpService: DefaultHttpServiceHandler(
            host: "localhost",
            port: 8080
        ),
        children: [
          // main gateway
        ]);
  }
}
```

### Run Server

````dart
void main() {
  runService(MyServer());
}
````

Now, server is ready from localhost but we have to define endpoints.

## 4 ) Create a `Endpoint`

Endpoints create functions where client requests are fulfilled.

"Endpoint" is a component. It can be put in Component parameters. But all ends in the component tree must end with
Endpoint and Endpoints do not have child/children.

![Endpoint](/home/mehmet/projects/style/packages/style/documentation/images/endpoint1.png)

**Boxes are `Component`, circles are `Endpoint`.**

Now let's create an Endpoint that response with "Hello World!".

```dart
class HelloEndpoint extends Endpoint {

  @override
  FutureOr<Object> onCall(Request request) {
    return "Hello World!";
  }
}
```

## 4 ) Put endpoints on routes

The main `Gateway` that handles requests is the `Server`'s `children` value.

There must be a `Route` between all `Endpoint` in the component tree and the `Gateway` above them.

Otherwise, you will get an error while the server is being built.

Now let's place the Endpoint to respond to the "http://localhost/hello" request.

```dart
class MyServer extends StatelessComponent {
  const MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        httpService: DefaultHttpServiceHandler(
            host: "localhost",
            port: 8080
        ),
        children: [
          Route("hello", root: HelloEndpoint())
        ]);
  }
}
```

`Route` takes a `root` and a `child`.

`root` handles requests ending with the entered path segment.

In this example `HelloEndpoint` handles request "http://localhost/hello"

If we want to process "hello/*" and its sub-routes, the `child` parameter must be defined.

Also, if we want to handle "hello/*" and its sub-routes with `HelloEndpoint`, `handleUnknownAsRoot` must be true.

## Request

Now start server with `dart run` or your IDE's run command.

And call "http://localhost/hello" .





#More Documentation Coming Soon !


# Packages
## style

base package

[pub package](https://pub.dev/packages/style_dart)

## style_cli

Command line app for debugging, monitoring, templating.

[pub package](https://pub.dev/packages/style_cli)

## style_test

Test framework for style

[pub package](https://pub.dev/packages/style_test)

## style_cron_job

Cron job definer and executor.

[medium article](https://itnext.io/flutter-dart-cron-jobs-90fa065ba8d2)

[pub package](https://pub.dev/packages/style_cron_job)

# Future

### remote service/server

Similar to Microservice architecture, you can use to base services (logger, crypto, data access, etc.) from remote
servers.

Services can be shared between servers(or microservices).

### monitoring app

Monitoring app shows server status , state properties, usage statistics , logs, component tree etc. The monitoring app
will be hosted by styledart.dev. It will also be available as open source.

### cli improvements

Many run/test options can be set by cli app. Also, cli app will be used for monitoring app.