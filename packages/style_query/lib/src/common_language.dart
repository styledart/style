/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
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

///
class CommonLanguage extends AccessLanguage {
  @override
  String get name => "common";
}

///
class CommonLanguageDelegate extends AccessLanguageDelegate<CommonLanguage> {
  @override
  CreateData<CommonLanguage> createFromRaw(Map<String, dynamic> raw) {
    return CommonCreate(raw);
  }

  @override
  Fields<CommonLanguage> fieldsFromRaw(Map<String, dynamic> raw) {
    return CommonFields(
        excludeKeys: raw['exclude'], includeKeys: raw['include']);
  }

  @override
  Access<CommonLanguage> fromCommonLanguage(CommonAccess access) {
    return access;
  }

  @override
  Pipeline<CommonLanguage> pipelineFromRaw(Map<String, dynamic> raw) {
    throw UnimplementedError();
  }

  @override
  Query<CommonLanguage> queryFromRaw(Map<String, dynamic> raw) {
    var filter = raw['filter'];

    FilterExpression? expression;

    if (filter is Map) {
      if (filter.length > 1) {



        expression = AndExpression([]);
      }


      if (filter.containsKey('or') || filter.containsKey('and')){

      }
    }


    return CommonQuery(identifier: raw['identifier']);
  }

  @override
  CommonAccess toCommonLanguage(covariant CommonAccess access) {
    return access;
  }

  @override
  UpdateData<CommonLanguage> updateFromRaw(Map<String, dynamic> raw) {
    return CommonUpdate(raw);
  }
}

///
class CommonQuery extends Query<CommonLanguage> {
  ///
  CommonQuery({this.identifier,
    FilterExpression? filter,
    Map<String, Sorting>? sort,
    this.offset,
    this.limit,
    this.fields})
      : sortExpression = SortExpression(sort ?? {});

  ///
  @override
  int? limit, offset;

  @override
  JsonMap toMap() =>
      {
        if (identifier != null) "id": identifier,
        if (offset != null) "offset": offset,
        if (limit != null) "limit": limit,
        if (fields != null) 'fields': fields!.toMap(),
        if (filter != null) 'filter': filter!.toMap(),
        if (sortExpression != null) 'sort': sortExpression!.sorts
      };

  @override
  String? identifier;

  @override
  Fields<CommonLanguage>? fields;

  @override
  FilterExpression? filter;

  @override
  SortExpression<AccessLanguage>? sortExpression;
}

///
class CommonUpdate extends UpdateData<CommonLanguage> {
  ///
  CommonUpdate(this._data);

  final JsonMap _data;

  @override
  UpdateDifference<T>? difference<T>(String key) {
    throw UnimplementedError();
  }

  @override
  JsonMap toMap() => _data;

  @override
  List<String> keysRenamed() => throw UnimplementedError();

  @override
  List<String> fieldsChanged() => throw UnimplementedError();

  @override
  List<String> fieldsRemoved() => throw UnimplementedError();

  @override
  Map<String, UpdateDifference<CommonLanguage>> differences() =>
      throw UnimplementedError();
}

///
class CommonCreate extends CreateData<CommonLanguage> {
  ///
  CommonCreate(this._data);

  final JsonMap _data;

  @override
  JsonMap toMap() => _data;

  @override
  String get id => throw UnimplementedError();
}

///
class CommonAccess extends Access<CommonLanguage> {
  ///
  CommonAccess({required super.type,
    required super.collection,
    CommonQuery? super.query,
    CommonCreate? super.create,
    CommonUpdate? super.update,
    OperationSettings? settings})
  /* : super(
            type: type,
            collection: collection,
            settings: settings,
            query: query,
            create: create,
            update: update)*/
  ;
}

///
class CommonFields extends Fields<CommonLanguage> {
  ///
  CommonFields({this.includeKeys, this.excludeKeys});

  @override
  final List<String>? excludeKeys;

  @override
  final List<String>? includeKeys;

  @override
  JsonMap toMap() => {'include': includeKeys, 'exclude': excludeKeys};
}
