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



import 'package:style_dart/style_dart.dart';

void main() {
  runService(_MyServer());
}



class _MyServer extends StatelessComponent {
  const _MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        dataAccess: DataAccess(SimpleCacheDataAccess(),
            defaultPermission: false, collections: []),
        children: [RestAccessPoint("api")]);
  }
}

