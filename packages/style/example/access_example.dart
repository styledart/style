/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
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
        children: [SimpleAccessPoint("api")]);
  }
}

