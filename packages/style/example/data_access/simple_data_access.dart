/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import 'dart:async';

import 'package:style_dart/style_dart.dart';

void main() {
  /// Run Service
  runService(StyleDataAccessExample());
}

class StyleDataAccessExample extends StatelessComponent {
  const StyleDataAccessExample({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    /// Main data access for app with permission defined for each Collection
    final mainDataAccess = DataAccess(EgMongoImplementation(), collections: [
      DbCollection("users",
          permissionHandler: PermissionHandler.custom(callback: (event) {
        /// permit if request token equals access's identifier.
        /// so own document
        return event.request?.token?.userId == event.access.identifier;
      }))
    ]);

    /// Data access for Payment system with default permissions
    final paymentDataAccess = DataAccess(EgSQLImplementation(),
        defaultPermission: false,
        defaultPermissionsByType: {
          DbOperationType.read: false,
          DbOperationType.create: true,
        },
        collections: [
          DbCollection("payments", triggers: [
            Trigger.onCreate(onEvent: (event) async {
              /// Do something on payment created
            })
          ])
        ]);

    /// Create Server
    return Server(

        /// DataAccess of server default
        /// Data access for all children is provided through
        /// this instance unless it is wrapped with a new data access.
        dataAccess: mainDataAccess,
        httpService: DefaultHttpServiceHandler(port: 100),
        rootEndpoint: Redirect("../index.html"),

        /// The main gateway of the server.
        children: [
          ContentDelivery("D:\\style\\packages\\style\\site\\build3\\web\\"),

          /// Simple Access point create a AccessEvent and
          /// operate with context's DataAccess
          ///
          /// [SimpleAccessPoint] has own [Route],
          /// so you shouldn't wrap a [Route],
          ///
          /// But you can use route as the sub-route with
          /// [routeTo] parameter must be true and wrapped with [Route].
          RestAccessPoint("api"),

          /// Custom Data Access
          RouteBase("hello", root: CustomDataAccess()),

          /// You can define custom access point that create
          /// your custom AccessEvent. Thus, you build an automation.
          RouteBase("custom_api", root: AccessPoint((request, ctx) {
            if (request.body is! JsonBody) {
              throw BadRequests();
            }
            return MyAccessEvent.fromRequest(request);
          })),

          /// You can define ServiceWrapper in any context.
          /// All endpoints under this context (unless re-wrapped)
          /// will use this DataAccess.
          ServiceWrapper<DataAccess>(
              service: paymentDataAccess, child: RestAccessPoint("payment"))
        ]);
  }
}

/// CustomDataAccess Endpoint
class CustomDataAccess extends Endpoint {
  CustomDataAccess() : super();

  @override
  // TODO: implement preferredType
  EndpointPreferredType? get preferredType => EndpointPreferredType.accessEvent;

  @override
  FutureOr<Object> onCall(Request request) async {
    /// Get Current DataAccess
    /// and read document identified as "world" in collection "hello"
    /// You can use [query] also
    var data = await DataAccess.of(context)
        .read(Read(request: request, collection: "hello", identifier: "world"));
    return (data);
  }
}

class MyAccessEvent extends AccessEvent {
  MyAccessEvent(Request request, Access access)
      : super(request: request, access: access);

  factory MyAccessEvent.fromRequest(Request request) {
    /// in this example our AccessEvent creating from Json
    var body = request.body?.data as Map<String, dynamic>;

    /// AccessEvent have many information about request side,
    /// base handler, cause, authorization token and etc.
    /// These information used for permission handlers, triggers and logging
    return MyAccessEvent(

        /// * is required

        /// * It contains all the information about the
        /// creator of the event.
        request,

        /// Access have information about access to data
        Access(

            /// * set access type with enum
            type: AccessType.values[body["type"]],

            /// * set which collection/table is the event on?
            collection: body["collection"],

            /// opt. Access with identifier
            identifier: body["identifier"],

            /// opt. data for create or update operations
            data: body["data"],

            /// opt. query
            query: body["query"]));
  }
}

/// These are examples.
/// MongoDb implementation is offered with [style_mongo](https://pub.dev/packages/style_mongo)
/// in the first release with Style.
///
///
/// If you want to develop a custom database implementation,
/// instead of this example, extend the [DataAccessImplementation].
class EgMongoImplementation extends SimpleCacheDataAccess {}

class EgSQLImplementation extends SimpleCacheDataAccess {}
