import 'dart:convert';

import 'package:style_query/style_query.dart';

void main() {

  var exp = AndExpression([
    EqualExpression("a", 10),
    EqualExpression("b", 20),
    EqualExpression("d", 40),
    NotEqual("d", 30),
    OrExpression([
      Greater("c", 8),
      Less("c", 10),
      GreaterOrEqual("d", 80),
      LessOrEqual("e", 5)
    ])
  ]);

  print(json.encode(exp.toMap()));
}

///
Map<String, dynamic> res = {
  "&&": [
    ["a", "==", 10],
    ["b", "==", 20],
    ["d", "==", 40],
    ["d", "!=", 30],
    {
      "||": [
        ["c", ">", 8],
        ["c", "<", 10],
        ["d", ">=", 80],
        ["e", "<=", 5]
      ]
    }
  ]
};
