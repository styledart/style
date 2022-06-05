/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import '../style_query.dart';
import 'style_query_base.dart';

///
abstract class FilterExpression {
  ///
  bool documentIsMatch(JsonMap map);

  ///
  dynamic toMap();
}

///
abstract class LogicalExpression extends FilterExpression {
  ///
  LogicalExpression(this.expressions) : assert(expressions.length > 1);

  ///
  List<FilterExpression> expressions;

  ///
  FilterExpression? filteredBy(String key) {
    var i = 0;
    FilterExpression? exp;
    while (i < expressions.length && exp == null) {
      var e = expressions[i];
      if (e is LogicalExpression) {
        exp = e.filteredBy(key);
      } else {
        exp = (e as MatchExpression).key == key ? e : null;
      }
      i++;
    }

    return exp;
  }
}

///
class AndExpression extends LogicalExpression {
  ///
  AndExpression(super.expressions);

  @override
  bool documentIsMatch(JsonMap map) {
    for (var expression in expressions) {
      if (!expression.documentIsMatch(map)) {
        return false;
      }
    }
    return true;
  }

  @override
  JsonMap toMap() {
    return {
      "&&": [...expressions.map((e) => e.toMap()).toList()]
    };
  }
}

///
class OrExpression extends LogicalExpression {
  ///
  OrExpression(super.expressions);

  @override
  bool documentIsMatch(JsonMap map) {
    for (var expression in expressions) {
      if (expression.documentIsMatch(map)) {
        return true;
      }
    }
    return false;
  }

  @override
  JsonMap toMap() {
    return {
      "||": [...expressions.map((e) => e.toMap()).toList()]
    };
  }
}

///
abstract class MatchExpression<Q extends Object> extends FilterExpression {
  ///
  MatchExpression(this.key, this.queryValue);

  ///
  Q queryValue;

  ///
  String key;

  ///
  String get expression;

  ///
  bool compareTo(dynamic value);

  @override
  List toMap() {
    return [key, expression, queryValue];
  }

  @override
  bool documentIsMatch(JsonMap map) {
    return compareTo(map[key]);
  }
}

///
class EqualExpression<Q extends Object> extends MatchExpression<Q> {
  ///
  EqualExpression(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) => value == queryValue;

  @override
  String get expression => "==";
}

///
class NotEqual<Q extends Object> extends MatchExpression<Q> {
  ///
  NotEqual(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) => value != queryValue;

  @override
  String get expression => "!=";
}

///
mixin ComparisonExpression<Q extends Comparable> on MatchExpression<Q> {
  ///
  bool get equal;

  ///
  bool get greater;
}

///
class Greater<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  Greater(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) =>
      value is Comparable && value.compareTo(queryValue) > 0;

  @override
  bool get equal => false;

  @override
  bool get greater => true;

  @override
  String get expression => ">";
}

///
class Less<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  Less(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) =>
      value is Comparable && value.compareTo(queryValue) < 0;

  @override
  bool get equal => false;

  @override
  bool get greater => false;

  @override
  String get expression => "<";
}

///
class GreaterOrEqual<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  GreaterOrEqual(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) =>
      value is Comparable && value.compareTo(queryValue) > -1;

  @override
  bool get equal => true;

  @override
  bool get greater => true;

  @override
  String get expression => ">=";
}

///
class LessOrEqual<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  LessOrEqual(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) =>
      value is Comparable && value.compareTo(queryValue) < 1;

  @override
  bool get equal => true;

  @override
  bool get greater => false;

  @override
  String get expression => "<=";
}
