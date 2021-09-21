
# Feature

- [ ] Microservice- Internal - External Service. Services be active or reactive with idle duration, terminal commands.
- [ ] Style Command Line App
- [ ] ViewEndpoint for Server Side Rendering. Endpoint built in initialize and serve views
- [ ] DataView . MVC Pattern
- [ ] Auto Api Documentation
- [ ] Role Based Admin Auth
- [ ] Differnt State for Each Client
- [ ] Monitoring- All calling  tree statuses, service statuses, client states
- [ ] Simple CRUD



## Components

### Create Service


*[host] will be used instead of "http://host" from now on.*

*All classes created as an example will begin with the prefix "My". Others are what Framework offers.*

```dart  
class MyServer extends StatelessComponent {  
  @override  
  Component build(BuildContext context) {  
    return Server(
		dataAccess: MyDataAccess(), // Or use style implemantation for mongo db or mysql.
        rootName: "my_server", // for internal ops. instead of hosts  
		children: {
	         "about": MyAbout(),
	         "api" : MyApiGateway()  
		},
		// "[host]/" is directed to
		rootEndpoint: MyUnknownEndpoint()
	);  
  }  
}
```
### Gateway

```dart
///  
class MyApiGateway extends StatelessComponent {  
  
  ///  
  const MyApiGateway({Key? key}) : super(key: key);  
  
  @override  
  Component build(BuildContext context) {  
    return Gateway(  
       	// "[host]/api" is directed to
        root: MyApiDocumentation(),
        children: {
	        // "[host]/api/v1" is directed to
	        "v1": MyV1Api(),
	        // "[host]/api/v2" is directed to
		    "v2": MyV2Api(),
		    // "[host]/api/{api-key}" is directed to
		    // for auto detect api version
		    // Look upper for GeneratedRedirect explanation 
			"{api-key}" : GeneratedRedirect()
		});  
  }  
}


// You can nest gateways.
class MyV1Api extends StatelessComponent {  
  const MyV1Api({Key? key}) : super(key: key);  
  
  @override  
  Component build(BuildContext context) {  
    return Gateway(  
       	// "[host]/api/v1" is directed to
        root: MyApiDocumentation(),
        children: {
	        // "[host]/api/v1/user" is directed to
	        "user": MyUserV1(),
	        "post" : MyPostV1()
		});  
  }  
}

```
### Path Route Segment

Let's say we have a path like "[host]/api/v1/user/{user_id}/...".
We want to send users in trend when this path is called "[host]/api/v1/user".
We can use a segment both as an endpoint and as a segment.
```dart
// You can nest gateways.
class MyUserV1 extends StatelessComponent {  
  const MyUserV1({Key? key}) : super(key: key);  
  
  @override  
  Component build(BuildContext context) {  
    return PathRoute(
	    // "[host]/api/v1/user" is called to endpoint
		root: SimpleEndpoint(
			onCall: (req) {
				// do something
				return req.response(data);
			}
		),
		// And we will create sub-segments
		child: PathRoute(
			segment: "{user_id}",
			// "[host]/api/v1/user/user1" is direct to
			child: RequestTransformer(
				onRequest : (req) {
					/// adapt to version 2
					return req;
				},
				child: Redirect("../../../v2/user")
				//or
				// child: Redirect("my_server/api/v2/user")
			)
		)
	);  
  }  
}
```

## Wrappers

### UnknownWrapper

Unknown routes everywhere it wrappers lead to this endpoint.
*Except under scopes in lower layers.*

```dart
UnknownWrapper(unknown: MyMediaUnknown(), child: MyPicture()),
```
### Error Wrapper

```dart
UnknownWrapper(error: MyErrorEndpoint(), child: MyPicture()),

class MyErrorEndpoint extends Endpoint {
	FutureOr<void> onError(StyleException exception, StackTrace stackTrace, Request request, BuildContext errorContext) async {
		//response own error message/view that specified for Picture Endpoint
	}
}

```

### DataAccess , Crypto , Logger
Parts wrapped in these components get this implementation in the DataAccess.of(context) call.
```dart
DataAccess(dataAccess: MyDataAccessImplement(), child: MyPicture()),
```
Sub-wraps are excluded.
Also this applies to Crypto and Logger.


## Redirects

#### Simple Redirect

Can redirect incoming requests to the specified route
Support path-parent relation like parent's parent's `new/path` :  `../../new/path`
```dart
Redirect("path/to")
```
Or you can find with context ancestor services root names like:

```dart
Redirect(context.findService("my_other_service").rootName + "/path/to")
//or
MyServiceState.of(context).rootName + "/path/to"
```


#### GeneratedRedirect

```dart
GeneratedRedirect(
	onRequest: (req) async {
		var keyData  = await DataAccess.of(context)
				.read("api_keys",req.path.arguments["api-key"])
		if (keyData["v"] == 1) {
			req.path.fullPath = "../v1";
		} else {
			req.path.fullPath = "../v2";
		}
		req.body["api_key"] = req.path.arguments["api-key"];
		return req;
	}
)
```

#### AuthRedirect
```dart
AuthRedirect(
	auth: "path/to/auth_user",
	admin: "path/to/admin",
	unauth: "path/to/login"
)
```

## Gates

Gates passes requests or responses through a controller.

#### Simple Gate

```dart
	// If onRequest return instance of request
	// request sent to child
	// or return response
	// the response is sent to the upper layer to be sent to the client.
	Gate(
		onRequest : (req) {
			// do something
			return req;
		},
		child: MyOtherEndpoint()
	)
```

#### Permssion

If the request does not meet the condition, it sends an permission denied error.

```dart
PermissionGate(
	// specify permission
	onRequestPermission : ()async {
		return true;
	}
	child: MyComponent()
)
```


#### AuthGate

If the request does not meet the condition, it sends an unauthorized error.

```dart
AuthGate(
	// specify auth required
	authRequired : true | false
	child: MyComponent()
)
```

#### AgentGate

```dart
AgentGate(
	// MyComponent get only request that agent is Web Socket
	// or internal. Not allowed Http request
	// if het http request response with error
	allowedAgents : [Agent.ws, Agent.internal]
	child: MyComponent()
)
```

#### Schema Gate
```dart
SchemaGate(
	// in default check body
	// you can specify to queryParameters
	// checkQueryParameters: false
	schema: jsonSchema
	child: MyComponent()
)
```
You can also create for response
```dart
/// If responded body not passed the schema, sent error to client
ResponseSchemaGate(
	schema: jsonSchema
	child: MyComponent()
)
```







