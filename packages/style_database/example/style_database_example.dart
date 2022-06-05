import 'dart:math';

import 'package:style_database/style_database.dart';
import 'package:style_query/style_query.dart';

void main() {
  // var nested = NestedIterator([
  //   [1 , 2 , 3],
  //   [4 , 5 , 6]
  // ]);
  //
  // while(nested.moveNext()) {
  //   print(nested.current);
  // }
  //
  // return ;

  var db = Database();

  db.collections['users'] = Collection('users', db);
  db.createIndexes<String>('users', 'count', unique: false);
  var collection = db.collections['users']!;

  var addSt = Stopwatch()..start();

  var i = 0;
  while (i < 10000) {
    collection.add({'count': Random().nextInt(10000)});
    i++;
  }

  addSt.stop();
  print(addSt.elapsedMicroseconds / 10000);
  print(1000000 / (addSt.elapsedMicroseconds / 10000));


  var firstRes =
      collection.read(query: CommonQuery(filter: Greater('count', 5000)));

  print((firstRes as JsonMap));

  var t = 0;
  var ii = 0;

  var st = Stopwatch()..start();
  while (ii < 1000000) {
    collection.read(query: CommonQuery(filter: Greater('count', 5000)));
    ii++;
  }
  t = st.elapsedMicroseconds;
  st.stop();
  print(t);
  print(t / 1000000);
  print(1000000 / (t / 1000000));
}

var dummy = [
  {'status': 1, 'count': 113, '__id': 'VCCQ388w1779e42f809K00Di3Os201'},
  {'status': 0, 'count': 115, '__id': '3N2W91F08Y3Ofic4tHHaD84wg52672'},
  {'status': 2, 'count': 122, '__id': '0GP5G66xq80xJm32E799J772Cp5790'},
  {'status': 2, 'count': 132, '__id': '6n8F1X5MbdY3ZI8364zU4A5jIk2413'},
  {'status': 1, 'count': 145, '__id': 'whH9HLyJ0t044w5Gi10k1y1460QU51'},
  {'status': 2, 'count': 156, '__id': '4286HY234t9U1886468n2623723305'},
  {'status': 0, 'count': 157, '__id': 'xw6rK9f7W88rs81B96Oxd411w380a9'},
  {'status': 3, 'count': 171, '__id': '663eU4OS732420V96145P486084013'},
  {'status': 0, 'count': 183, '__id': 'wFg8rf8d8dOc9DC120U1304hO6q602'},
  {'status': 2, 'count': 221, '__id': 'iTe1oL86RV6if24xx6M0aJW7484897'},
  {'status': 2, 'count': 222, '__id': 'Po3X38Vu0YR1XhU04i237x6NX6473D'},
  {'status': 1, 'count': 230, '__id': '6AdDRypA04r3yqhdaxj28205796584'},
  {'status': 3, 'count': 234, '__id': '86h4d65268t7UZ260hhp4GCl1rEBb3'},
  {'status': 1, 'count': 236, '__id': '301gpXo2PiW3jD6XZ1ARt1910B5754'},
  {'status': 1, 'count': 241, '__id': 'aXb9LMC0DU152159fM4608V295j708'},
  {'status': 3, 'count': 251, '__id': '4X7KT543J7AF9gn9S3k40jW906e123'},
  {'status': 3, 'count': 263, '__id': 'j6a78Qz45xR3Nc993C52EuM44dM9P9'},
  {'status': 3, 'count': 264, '__id': '23j3V219N287983enU711k99321557'},
  {'status': 1, 'count': 276, '__id': '3k2mmn7uSdvOVW58dsL3s968905442'},
  {'status': 0, 'count': 277, '__id': 'WJH8KQ6TLpu394L4A81mR7q3726H53'},
  {'status': 1, 'count': 285, '__id': 'l88k0US6Vp28FA4ior154349R22952'}
];
