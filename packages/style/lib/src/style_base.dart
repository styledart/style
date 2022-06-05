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
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:json_schema2/json_schema2.dart';
import 'package:meta/meta.dart';
import 'package:queue/queue.dart' as q;
import 'package:style_cron_job/style_cron_job.dart';
import 'package:style_query/style_query.dart';
import 'package:style_random/style_random.dart';

import 'functions/uint8_merge.dart';
import 'models/json_schema.dart';

part 'component/base_services/authorization/authorization.dart';
part 'component/base_services/authorization/confirmation/confirmatories.dart';
part 'component/base_services/authorization/confirmation/confirmatory.dart';
part 'component/base_services/base.dart';
part 'component/base_services/communication.dart';
part 'component/base_services/crypto.dart';
part 'component/base_services/data_access/data.dart';
part 'component/base_services/data_access/permission.dart';
part 'component/base_services/data_access/trigger.dart';
part 'component/base_services/http.dart';
part 'component/base_services/logger.dart';
part 'component/base_services/web_socket.dart';
part 'component/calling.dart';
part 'component/component_base.dart';
part 'component/components/cache_control.dart';
part 'component/components/cron_job.dart';
part 'component/components/endpoints.dart';
part 'component/components/gate.dart';
part 'component/components/gateway.dart';
part 'component/components/other.dart';
part 'component/components/redirect.dart';
part 'component/components/route.dart';
part 'component/components/service.dart';
part 'component/components/trigger.dart';
part 'component/components/wrapper.dart';
part 'component/context.dart';
part 'component/endpoint.dart';
part 'component/run.dart';
part 'enums.dart';
part 'exception/exception_handler.dart';
part 'exception/style_exception.dart';
part 'models/data_access/access.dart';
part 'models/data_access/access_event.dart';
part 'models/data_access/access_language.dart';
part 'models/data_access/collection.dart';
part 'models/data_access/permission_handler.dart';
part 'models/data_access/trigger.dart';
part 'models/request/agent.dart';
part 'models/request/cause.dart';
part 'models/request/context.dart';
part 'models/request/request.dart';
part 'models/request/token.dart';
