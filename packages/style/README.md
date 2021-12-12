


For more accurate information look this [article](https://itnext.io/style-backend-framework-d544bdb78a36)

[Pub Package](https://pub.dev/packages/style_dart)

Development Log 1 : [Exception Handling](https://itnext.io/exception-handling-with-style-6020f01af7d8)

Development Log 2 : [Endpoint](https://medium.com/@mehmet_yaz/style-development-log-2-endpoint-c0a0566b44db)

Articles is free-read.




[comment]: <> (## Components)

[comment]: <> (### Create Service)

[comment]: <> (*[host] will be used instead of "http://host" from now on.*)

[comment]: <> (*All classes created as an example will begin with the prefix "My". Others are what Framework offers.*)

[comment]: <> (```dart  )

[comment]: <> (class MyServer extends StatelessComponent {  )

[comment]: <> (  @override  )

[comment]: <> (  Component build&#40;BuildContext context&#41; {  )

[comment]: <> (    return Server&#40;)

[comment]: <> (		dataAccess: MyDataAccess&#40;&#41;, // Or use style implemantation for mongo db or mysql.)

[comment]: <> (        rootName: "my_server", // for internal ops. instead of hosts  )

[comment]: <> (		children: {)

[comment]: <> (	         "about": MyAbout&#40;&#41;,)

[comment]: <> (	         "api" : MyApiGateway&#40;&#41;  )

[comment]: <> (		},)

[comment]: <> (		// "[host]/" is directed to)

[comment]: <> (		rootEndpoint: MyUnknownEndpoint&#40;&#41;)

[comment]: <> (	&#41;;  )

[comment]: <> (  }  )

[comment]: <> (})

[comment]: <> (```)

[comment]: <> (### Gateway)

[comment]: <> (```dart)

[comment]: <> (///  )

[comment]: <> (class MyApiGateway extends StatelessComponent {  )
  
[comment]: <> (  ///  )

[comment]: <> (  const MyApiGateway&#40;{Key? key}&#41; : super&#40;key: key&#41;;  )
  
[comment]: <> (  @override  )

[comment]: <> (  Component build&#40;BuildContext context&#41; {  )

[comment]: <> (    return Gateway&#40;  )

[comment]: <> (       	// "[host]/api" is directed to)

[comment]: <> (        root: MyApiDocumentation&#40;&#41;,)

[comment]: <> (        children: {)

[comment]: <> (	        // "[host]/api/v1" is directed to)

[comment]: <> (	        "v1": MyV1Api&#40;&#41;,)

[comment]: <> (	        // "[host]/api/v2" is directed to)

[comment]: <> (		    "v2": MyV2Api&#40;&#41;,)

[comment]: <> (		    // "[host]/api/{api-key}" is directed to)

[comment]: <> (		    // for auto detect api version)

[comment]: <> (		    // Look upper for GeneratedRedirect explanation )

[comment]: <> (			"{api-key}" : GeneratedRedirect&#40;&#41;)

[comment]: <> (		}&#41;;  )

[comment]: <> (  }  )

[comment]: <> (})


[comment]: <> (// You can nest gateways.)

[comment]: <> (class MyV1Api extends StatelessComponent {  )

[comment]: <> (  const MyV1Api&#40;{Key? key}&#41; : super&#40;key: key&#41;;  )
  
[comment]: <> (  @override  )

[comment]: <> (  Component build&#40;BuildContext context&#41; {  )

[comment]: <> (    return Gateway&#40;  )

[comment]: <> (       	// "[host]/api/v1" is directed to)

[comment]: <> (        root: MyApiDocumentation&#40;&#41;,)

[comment]: <> (        children: {)

[comment]: <> (	        // "[host]/api/v1/user" is directed to)

[comment]: <> (	        "user": MyUserV1&#40;&#41;,)

[comment]: <> (	        "post" : MyPostV1&#40;&#41;)

[comment]: <> (		}&#41;;  )

[comment]: <> (  }  )

[comment]: <> (})

[comment]: <> (```)

[comment]: <> (### Path Route Segment)

[comment]: <> (Let's say we have a path like "[host]/api/v1/user/{user_id}/...".)

[comment]: <> (We want to send users in trend when this path is called "[host]/api/v1/user".)

[comment]: <> (We can use a segment both as an endpoint and as a segment.)

[comment]: <> (```dart)

[comment]: <> (// You can nest gateways.)

[comment]: <> (class MyUserV1 extends StatelessComponent {  )

[comment]: <> (  const MyUserV1&#40;{Key? key}&#41; : super&#40;key: key&#41;;  )
  
[comment]: <> (  @override  )

[comment]: <> (  Component build&#40;BuildContext context&#41; {  )

[comment]: <> (    return PathRoute&#40;)

[comment]: <> (	    // "[host]/api/v1/user" is called to endpoint)

[comment]: <> (		root: SimpleEndpoint&#40;)

[comment]: <> (			onCall: &#40;req&#41; {)

[comment]: <> (				// do something)

[comment]: <> (				return req.response&#40;data&#41;;)

[comment]: <> (			})

[comment]: <> (		&#41;,)

[comment]: <> (		// And we will create sub-segments)

[comment]: <> (		child: PathRoute&#40;)

[comment]: <> (			segment: "{user_id}",)

[comment]: <> (			// "[host]/api/v1/user/user1" is direct to)

[comment]: <> (			child: RequestTransformer&#40;)

[comment]: <> (				onRequest : &#40;req&#41; {)

[comment]: <> (					/// adapt to version 2)

[comment]: <> (					return req;)

[comment]: <> (				},)

[comment]: <> (				child: Redirect&#40;"../../../v2/user"&#41;)

[comment]: <> (				//or)

[comment]: <> (				// child: Redirect&#40;"my_server/api/v2/user"&#41;)

[comment]: <> (			&#41;)

[comment]: <> (		&#41;)

[comment]: <> (	&#41;;  )

[comment]: <> (  }  )

[comment]: <> (})

[comment]: <> (```)

[comment]: <> (## Wrappers)

[comment]: <> (### UnknownWrapper)

[comment]: <> (Unknown routes everywhere it wrappers lead to this endpoint.)

[comment]: <> (*Except under scopes in lower layers.*)

[comment]: <> (```dart)

[comment]: <> (UnknownWrapper&#40;unknown: MyMediaUnknown&#40;&#41;, child: MyPicture&#40;&#41;&#41;,)

[comment]: <> (```)

[comment]: <> (### Error Wrapper)

[comment]: <> (```dart)

[comment]: <> (UnknownWrapper&#40;error: MyErrorEndpoint&#40;&#41;, child: MyPicture&#40;&#41;&#41;,)

[comment]: <> (class MyErrorEndpoint extends Endpoint {)

[comment]: <> (	FutureOr<void> onError&#40;StyleException exception, StackTrace stackTrace, Request request, BuildContext errorContext&#41; async {)

[comment]: <> (		//response own error message/view that specified for Picture Endpoint)

[comment]: <> (	})

[comment]: <> (})

[comment]: <> (```)

[comment]: <> (### DataAccess , Crypto , Logger)

[comment]: <> (Parts wrapped in these components get this implementation in the DataAccess.of&#40;context&#41; call.)

[comment]: <> (```dart)

[comment]: <> (DataAccess&#40;dataAccess: MyDataAccessImplement&#40;&#41;, child: MyPicture&#40;&#41;&#41;,)

[comment]: <> (```)

[comment]: <> (Sub-wraps are excluded.)

[comment]: <> (Also this applies to Crypto and Logger.)


[comment]: <> (## Redirects)

[comment]: <> (#### Simple Redirect)

[comment]: <> (Can redirect incoming requests to the specified route)

[comment]: <> (Support path-parent relation like parent's parent's `new/path` :  `../../new/path`)

[comment]: <> (```dart)

[comment]: <> (Redirect&#40;"path/to"&#41;)

[comment]: <> (```)

[comment]: <> (Or you can find with context ancestor services root names like:)

[comment]: <> (```dart)

[comment]: <> (Redirect&#40;context.findService&#40;"my_other_service"&#41;.rootName + "/path/to"&#41;)

[comment]: <> (//or)

[comment]: <> (MyServiceState.of&#40;context&#41;.rootName + "/path/to")

[comment]: <> (```)


[comment]: <> (#### GeneratedRedirect)

[comment]: <> (```dart)

[comment]: <> (GeneratedRedirect&#40;)

[comment]: <> (	onRequest: &#40;req&#41; async {)

[comment]: <> (		var keyData  = await DataAccess.of&#40;context&#41;)

[comment]: <> (				.read&#40;"api_keys",req.path.arguments["api-key"]&#41;)

[comment]: <> (		if &#40;keyData["v"] == 1&#41; {)

[comment]: <> (			req.path.fullPath = "../v1";)

[comment]: <> (		} else {)

[comment]: <> (			req.path.fullPath = "../v2";)

[comment]: <> (		})

[comment]: <> (		req.body["api_key"] = req.path.arguments["api-key"];)

[comment]: <> (		return req;)

[comment]: <> (	})

[comment]: <> (&#41;)

[comment]: <> (```)

[comment]: <> (#### AuthRedirect)

[comment]: <> (```dart)

[comment]: <> (AuthRedirect&#40;)

[comment]: <> (	auth: "path/to/auth_user",)

[comment]: <> (	admin: "path/to/admin",)

[comment]: <> (	unauth: "path/to/login")

[comment]: <> (&#41;)

[comment]: <> (```)

[comment]: <> (## Gates)

[comment]: <> (Gates passes requests or responses through a controller.)

[comment]: <> (#### Simple Gate)

[comment]: <> (```dart)

[comment]: <> (	// If onRequest return instance of request)

[comment]: <> (	// request sent to child)

[comment]: <> (	// or return response)

[comment]: <> (	// the response is sent to the upper layer to be sent to the client.)

[comment]: <> (	Gate&#40;)

[comment]: <> (		onRequest : &#40;req&#41; {)

[comment]: <> (			// do something)

[comment]: <> (			return req;)

[comment]: <> (		},)

[comment]: <> (		child: MyOtherEndpoint&#40;&#41;)

[comment]: <> (	&#41;)

[comment]: <> (```)

[comment]: <> (#### Permssion)

[comment]: <> (If the request does not meet the condition, it sends an permission denied error.)

[comment]: <> (```dart)

[comment]: <> (PermissionGate&#40;)

[comment]: <> (	// specify permission)

[comment]: <> (	onRequestPermission : &#40;&#41;async {)

[comment]: <> (		return true;)

[comment]: <> (	})

[comment]: <> (	child: MyComponent&#40;&#41;)

[comment]: <> (&#41;)

[comment]: <> (```)


[comment]: <> (#### AuthGate)

[comment]: <> (If the request does not meet the condition, it sends an unauthorized error.)

[comment]: <> (```dart)

[comment]: <> (AuthGate&#40;)

[comment]: <> (	// specify auth required)

[comment]: <> (	authRequired : true | false)

[comment]: <> (	child: MyComponent&#40;&#41;)

[comment]: <> (&#41;)

[comment]: <> (```)

[comment]: <> (#### AgentGate)

[comment]: <> (```dart)

[comment]: <> (AgentGate&#40;)

[comment]: <> (	// MyComponent get only request that agent is Web Socket)

[comment]: <> (	// or internal. Not allowed Http request)

[comment]: <> (	// if het http request response with error)

[comment]: <> (	allowedAgents : [Agent.ws, Agent.internal])

[comment]: <> (	child: MyComponent&#40;&#41;)

[comment]: <> (&#41;)

[comment]: <> (```)

[comment]: <> (#### Schema Gate)

[comment]: <> (```dart)

[comment]: <> (SchemaGate&#40;)

[comment]: <> (	// in default check body)

[comment]: <> (	// you can specify to queryParameters)

[comment]: <> (	// checkQueryParameters: false)

[comment]: <> (	schema: jsonSchema)

[comment]: <> (	child: MyComponent&#40;&#41;)

[comment]: <> (&#41;)

[comment]: <> (```)

[comment]: <> (You can also create for response)

[comment]: <> (```dart)

[comment]: <> (/// If responded body not passed the schema, sent error to client)

[comment]: <> (ResponseSchemaGate&#40;)

[comment]: <> (	schema: jsonSchema)

[comment]: <> (	child: MyComponent&#40;&#41;)

[comment]: <> (&#41;)

[comment]: <> (```)


[comment]: <> (# Feature)

[comment]: <> (- [ ] Microservice- Internal - External Service. Services be active or reactive with idle duration, terminal commands.)

[comment]: <> (- [ ] Style Command Line App)

[comment]: <> (- [ ] ViewEndpoint for Server Side Rendering. Endpoint built in initialize and serve views)

[comment]: <> (- [ ] DataView . MVC Pattern)

[comment]: <> (- [ ] Auto Api Documentation)

[comment]: <> (- [ ] Role Based Admin Auth)

[comment]: <> (- [ ] Differnt State for Each Client)

[comment]: <> (- [ ] Monitoring- All calling  tree statuses, service statuses, client states)

[comment]: <> (- [ ] Simple CRUD)
