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

import 'dart:convert';
import 'dart:math';

import 'package:json_schema2/json_schema2.dart';

///
class Instance {
  ///
  Instance(this.data, {this.path = ''});

  ///
  dynamic data;

  ///
  String? path;

  @override
  String toString() => data.toString();
}

///
class StyleValidationError {
  StyleValidationError._(
      {required this.schemaPath, required this.type, this.payload});

  ///
  String schemaPath;

  ///
  Map<String, dynamic>? payload;

  ///
  String type;

  ///
  MapEntry<String, Map<String, dynamic>> toMapEntry() {
    return MapEntry(
        schemaPath.isEmpty ? "root" : schemaPath,
        {
          "type": type,
        }..addAll(payload ?? {}));
  }
}

/// Initialized with schema, validates instances against it
class StyleValidator {
  ///
  StyleValidator(this._rootSchema);

  final JsonSchema? _rootSchema;
  List<StyleValidationError> _errors = [];
  late bool _reportMultipleErrors;

  ///
  List<String> get errors => _errors.map((e) => e.toString()).toList();

  ///
  List<StyleValidationError> get errorObjects => _errors;

  /// Validate the [instance] against the this validator's schema
  bool validate(dynamic instance,
      {bool reportMultipleErrors = false, bool parseJson = false}) {
    // _logger.info('Validating ${instance.runtimeType}
    // :$instance on ${_rootSchema}');
    // TODO: re-add logger

    dynamic data = instance;
    if (parseJson && instance is String) {
      try {
        data = json.decode(instance);
      } catch (e) {
        throw ArgumentError(
            'JSON instance provided to validate is not valid JSON.');
      }
    }

    _reportMultipleErrors = reportMultipleErrors;
    _errors = [];
    if (!_reportMultipleErrors) {
      try {
        _validate(_rootSchema!, data);
        return true;
      } on FormatException {
        return false;
      } catch (e) {
        // _logger.shout('Unexpected Exception: $e'); TODO: re-add logger
        return false;
      }
    }

    _validate(_rootSchema!, data);
    return _errors.isEmpty == true;
  }

  static bool _typeMatch(
      SchemaType? type, JsonSchema schema, dynamic instance) {
    switch (type) {
      case SchemaType.object:
        return instance is Map;
      case SchemaType.string:
        return instance is String;
      case SchemaType.integer:
        return instance is int ||
            (schema.schemaVersion == SchemaVersion.draft6 &&
                instance is num &&
                instance.remainder(1) == 0);
      case SchemaType.number:
        return instance is num;
      case SchemaType.array:
        return instance is List;
      case SchemaType.boolean:
        return instance is bool;
      case SchemaType.nullValue:
        return instance == null;
    }
    return false;
  }

  void _numberValidation(JsonSchema schema, Instance instance) {
    final num? n = instance.data;

    final maximum = schema.maximum;
    final minimum = schema.minimum;
    final exclusiveMaximum = schema.exclusiveMaximum;
    final exclusiveMinimum = schema.exclusiveMinimum;

    if (exclusiveMaximum != null) {
      if (n! >= exclusiveMaximum) {
        _err(
            msg: "exclusive_max_exceeded",
            schemaPath: schema.path!,
            payload: {"exclusive_max": exclusiveMaximum, "value": n});
      }
    } else if (maximum != null) {
      if (n! > maximum) {
        _err(
            msg: "maximum_exceeded",
            schemaPath: schema.path!,
            payload: {"maximum": maximum, "value": n});
      }
    }

    if (exclusiveMinimum != null) {
      if (n! <= exclusiveMinimum) {
        _err(
            msg: "exclusive_min_exceeded",
            schemaPath: schema.path!,
            payload: {"exclusive_min": exclusiveMinimum, "value": n});
      }
    } else if (minimum != null) {
      if (n! < minimum) {
        _err(
            msg: "minimum_violated",
            schemaPath: schema.path!,
            payload: {"minimum": minimum, "value": n});
      }
    }

    final multipleOf = schema.multipleOf;
    if (multipleOf != null) {
      if (multipleOf is int && n is int) {
        if (0 != n % multipleOf) {
          _err(
              msg: "multiple_of_violated",
              schemaPath: schema.path!,
              payload: {"multiple_of": multipleOf, "value": n});
        }
      } else {
        final result = n! / multipleOf;
        if (result.truncate() != result) {
          _err(
              msg: "multiple_of_violated",
              schemaPath: schema.path!,
              payload: {"multiple_of": multipleOf, "value": n});
        }
      }
    }
  }

  void _typeValidation(JsonSchema schema, dynamic instance) {
    final typeList = schema.typeList;
    if (typeList?.isNotEmpty == true) {
      if (!typeList!.any((type) => _typeMatch(type, schema, instance.data))) {
        _err(
            msg: "type_validation_violated",
            schemaPath: schema.path!,
            payload: {"wanted": typeList});
      }
    }
  }

  void _constValidation(JsonSchema schema, dynamic instance) {
    if (schema.hasConst &&
        !JsonSchemaUtils.jsonEqual(instance.data, schema.constValue)) {
      _err(
          msg: "const_violated",
          schemaPath: schema.path!,
          payload: {"instance_path": instance.path});
    }
  }

  void _enumValidation(JsonSchema schema, dynamic instance) {
    final enumValues = schema.enumValues;
    if (enumValues?.isNotEmpty == true) {
      try {
        enumValues!
            .singleWhere((v) => JsonSchemaUtils.jsonEqual(instance.data, v));
      } on StateError {
        _err(msg: "enum_violated", schemaPath: schema.path!);
      }
    }
  }

  void _stringValidation(JsonSchema schema, Instance instance) {
    final actual = instance.data.runes.length;
    final minLength = schema.minLength;
    final maxLength = schema.maxLength;
    if (maxLength is int && actual > maxLength) {
      _err(
          msg: "max_length_exceeded",
          schemaPath: schema.path!,
          payload: {"max_length": maxLength, "actual": actual});
    } else if (minLength is int && actual < minLength) {
      _err(
          msg: "min_length_exceeded",
          schemaPath: schema.path!,
          payload: {"min_length": maxLength, "actual": actual});
    }
    final pattern = schema.pattern;
    if (pattern != null && !pattern.hasMatch(instance.data)) {
      _err(
          msg: "pattern_violated",
          schemaPath: schema.path!,
          payload: {"pattern": pattern});
    }
  }

  void _itemsValidation(JsonSchema schema, Instance instance) {
    final int? actual = instance.data.length;

    final singleSchema = schema.items;
    if (singleSchema != null) {
      instance.data.asMap().forEach((index, item) {
        final itemInstance = Instance(item, path: '${instance.path}/$index');
        _validate(singleSchema, itemInstance);
      });
    } else {
      final items = schema.itemsList;

      if (items != null) {
        final expected = items.length;
        final end = min(expected, actual!);
        for (var i = 0; i < end; i++) {
          final itemInstance =
              Instance(instance.data[i], path: '${instance.path}/$i');
          _validate(items[i], itemInstance);
        }
        if (schema.additionalItemsSchema != null) {
          for (var i = end; i < actual; i++) {
            final itemInstance =
                Instance(instance.data[i], path: '${instance.path}/$i');
            _validate(schema.additionalItemsSchema!, itemInstance);
          }
        } else if (schema.additionalItemsBool != null) {
          if (!schema.additionalItemsBool! && actual > end) {
            _err(msg: "additional_items_false", schemaPath: schema.path!);
          }
        }
      }
    }

    final maxItems = schema.maxItems;
    final minItems = schema.minItems;
    if (maxItems is int && actual! > maxItems) {
      _err(
          msg: "max_item_exceeded",
          schemaPath: schema.path!,
          payload: {"actual": actual, "max_items": maxItems});
    } else if (schema.minItems is int && actual! < schema.minItems!) {
      _err(
          msg: "min_item_violated",
          schemaPath: schema.path!,
          payload: {"actual": actual, "min_items": minItems});
    }

    if (schema.uniqueItems) {
      final end = instance.data.length;
      final penultimate = end - 1;
      for (var i = 0; i < penultimate; i++) {
        for (var j = i + 1; j < end; j++) {
          if (JsonSchemaUtils.jsonEqual(instance.data[i], instance.data[j])) {
            _err(
                msg: "unique_item_violated",
                schemaPath: schema.path!,
                payload: {"a": i, "b": j});
          }
        }
      }
    }

    if (schema.contains != null) {
      if (!instance.data
          .any((item) => StyleValidator(schema.contains).validate(item))) {
        _err(msg: "contains_violated", schemaPath: schema.path!);
      }
    }
  }

  void _validateAllOf(JsonSchema schema, Instance instance) {
    if (!schema.allOf.every((s) => StyleValidator(s).validate(instance))) {
      _err(
          msg: "all_of_violated",
          schemaPath: schema.path!,
          payload: {"all_of": schema.allOf});
    }
  }

  void _validateAnyOf(JsonSchema schema, Instance instance) {
    if (!schema.anyOf.any((s) => StyleValidator(s).validate(instance))) {
      // TODO: deal with /anyOf
      _err(
          msg: "any_of_violated",
          schemaPath: schema.path!,
          payload: {"any_of": schema.anyOf});
    }
  }

  // ignore_for_file: avoid_catching_errors

  void _validateOneOf(JsonSchema schema, Instance instance) {
    try {
      schema.oneOf.singleWhere((s) => StyleValidator(s).validate(instance));
    } on StateError catch (notOneOf) {
      _err(
          msg: "one_of_violated",
          schemaPath: schema.path!,
          payload: {"one_of": schema.oneOf, "not_one_of": notOneOf.toString()});
    }
  }

  void _validateNot(JsonSchema schema, Instance instance) {
    if (StyleValidator(schema.notSchema).validate(instance)) {
      // TODO: deal with .notSchema
      _err(
          msg: "not_schema_violated",
          schemaPath: schema.path!,
          payload: {"not_schema": schema.notSchema!.path!});
    }
  }

  void _validateFormat(JsonSchema schema, Instance instance) {
    if (instance.data is! String) {
      _err(
          msg: "format_not_string",
          schemaPath: schema.path!,
          payload: {"actual": instance.data.runtimeType});
      return;
    }

    // ignore_for_file: avoid_catches_without_on_clauses
    switch (schema.format) {
      case 'date-time':
        {
          try {
            DateTime.parse(instance.data);
          } catch (e) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {"accepted": "date_time"});
          }
        }
        break;
      case 'uri':
        {
          final isValid =
              defaultValidators.uriValidator as bool Function(String?)? ??
                  (_) => false;

          if (!isValid(instance.data)) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {"accepted": "uri"});
          }
        }
        break;
      case 'uri-reference':
        {
          if (schema.schemaVersion != SchemaVersion.draft6) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {
                  "accepted": "draft6_or_higher",
                  "format": schema.format
                });
          }
          final isValid = defaultValidators.uriReferenceValidator as bool
                  Function(String?)? ??
              (_) => false;

          if (!isValid(instance.data)) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {"accepted": "uri-reference"});
          }
        }
        break;
      case 'uri-template':
        {
          if (schema.schemaVersion != SchemaVersion.draft6) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {
                  "accepted": "uri-draft6_or_higher",
                  "format": schema.format
                });
          }
          final isValid = defaultValidators.uriTemplateValidator as bool
                  Function(String?)? ??
              (_) => false;

          if (!isValid(instance.data)) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {
                  "accepted": "uri_template",
                });
          }
        }
        break;
      case 'email':
        {
          final isValid =
              defaultValidators.emailValidator as bool Function(String?)? ??
                  (_) => false;

          if (!isValid(instance.data)) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {
                  "accepted": "uri-draft6_or_higher",
                  "format": schema.format
                });
          }
        }
        break;
      case 'ipv4':
        {
          if (JsonSchemaValidationRegexes.ipv4.firstMatch(instance.data) ==
              null) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {
                  "accepted": "ipv4",
                });
          }
        }
        break;
      case 'ipv6':
        {
          if (JsonSchemaValidationRegexes.ipv6.firstMatch(instance.data) ==
              null) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {
                  "accepted": "ipv6",
                });
          }
        }
        break;
      case 'hostname':
        {
          if (JsonSchemaValidationRegexes.hostname.firstMatch(instance.data) ==
              null) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {
                  "accepted": "host_name",
                });
          }
        }
        break;
      case 'json-pointer':
        {
          if (schema.schemaVersion != SchemaVersion.draft6) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {
                  "accepted": "uri-draft6_or_higher",
                  "format": schema.format
                });
          }
          if (JsonSchemaValidationRegexes.jsonPointer
                  .firstMatch(instance.data) ==
              null) {
            _err(
                msg: "format_not_accepted",
                schemaPath: schema.path!,
                payload: {
                  "accepted": "json_pointer",
                });
          }
        }
        break;
      default:
        {
          _err(
              msg: "format_not_accepted",
              schemaPath: schema.path!,
              payload: {"accepted": "any", "format": schema.format});
        }
    }
  }

  void _objectPropertyValidation(JsonSchema schema, Instance instance) {
    final propMustValidate = schema.additionalPropertiesBool != null &&
        !schema.additionalPropertiesBool!;

    instance.data.forEach((k, v) {
      // Validate property names against the provided schema, if any.
      if (schema.propertyNamesSchema != null) {
        _validate(schema.propertyNamesSchema!, k);
      }

      final newInstance = Instance(v, path: '${instance.path}/$k');

      var propCovered = false;
      final propSchema = schema.properties[k];
      if (propSchema != null) {
        _validate(propSchema, newInstance);
        propCovered = true;
      }

      schema.patternProperties.forEach((regex, patternSchema) {
        if (regex.hasMatch(k)) {
          _validate(patternSchema, newInstance);
          propCovered = true;
        }
      });

      if (!propCovered) {
        if (schema.additionalPropertiesSchema != null) {
          _validate(schema.additionalPropertiesSchema!, newInstance);
        } else if (propMustValidate) {
          _err(
              msg: "unallowed_additional_property",
              schemaPath: schema.path!,
              payload: {"property": k});
        }
      }
    });
  }

  void _propertyDependenciesValidation(JsonSchema schema, Instance instance) {
    schema.propertyDependencies?.forEach((k, dependencies) {
      if (instance.data.containsKey(k)) {
        if (!dependencies.every((prop) => instance.data.containsKey(prop))) {
          _err(
              msg: "property_required",
              schemaPath: schema.path!,
              payload: {"property": k, "dependencies": dependencies});
        }
      }
    });
  }

  void _schemaDependenciesValidation(JsonSchema schema, Instance instance) {
    schema.schemaDependencies?.forEach((k, otherSchema) {
      if (instance.data.containsKey(k)) {
        if (!StyleValidator(otherSchema).validate(instance)) {
          _err(msg: "property_violated", schemaPath: schema.path!, payload: {
            "property": k,
          });
        }
      }
    });
  }

  void _objectValidation(JsonSchema schema, Instance instance) {
    // Min / Max Props
    final numProps = instance.data.length;
    final minProps = schema.minProperties;
    final maxProps = schema.maxProperties;
    if (numProps < minProps) {
      _err(
          msg: "min_properties_violated",
          schemaPath: schema.path!,
          payload: {"num": numProps, "min": minProps});
    } else if (maxProps != null && numProps > maxProps) {
      _err(
          msg: "max_properties_violated",
          schemaPath: schema.path!,
          payload: {"num": numProps, "max": maxProps});
    }

    // Required Properties
    if (schema.requiredProperties != null) {
      for (var prop in schema.requiredProperties!) {
        if (!instance.data.containsKey(prop)) {
          _err(
              msg: "missing_property",
              schemaPath: schema.path!.isEmpty ? "root/$prop" : schema.path!,
              payload: {
                "missing": prop,
              });
        }
      }
    }

    _objectPropertyValidation(schema, instance);

    if (schema.propertyDependencies != null) {
      _propertyDependenciesValidation(schema, instance);
    }

    if (schema.schemaDependencies != null) {
      _schemaDependenciesValidation(schema, instance);
    }
  }

  void _validate(JsonSchema schema, dynamic instance) {
    if (instance is! Instance) {
      instance = Instance(instance);
    }

    /// If the [JsonSchema] is a bool, always return this value.
    if (schema.schemaBool != null) {
      if (schema.schemaBool == false) {
        _err(
          msg: "never_validate",
          schemaPath: schema.path!,
        );
      }
      return;
    }

    /// If the [JsonSchema] being validated is a ref, pull the ref
    /// from the [refMap] instead.
    if (schema.ref != null) {
      final path = schema.root!.endPath(schema.ref.toString());
      schema = schema.root!.refMap![path]!;
    }
    _typeValidation(schema, instance);
    _constValidation(schema, instance);
    _enumValidation(schema, instance);
    if (instance.data is List) {
      _itemsValidation(schema, instance);
    }
    if (instance.data is String) {
      _stringValidation(schema, instance);
    }
    if (instance.data is num) {
      _numberValidation(schema, instance);
    }
    if (schema.allOf.isNotEmpty == true) {
      _validateAllOf(schema, instance);
    }
    if (schema.anyOf.isNotEmpty == true) {
      _validateAnyOf(schema, instance);
    }
    if (schema.oneOf.isNotEmpty == true) {
      _validateOneOf(schema, instance);
    }
    if (schema.notSchema != null) {
      _validateNot(schema, instance);
    }
    if (schema.format != null) {
      _validateFormat(schema, instance);
    }
    if (instance.data is Map) {
      _objectValidation(schema, instance);
    }
  }

  void _err(
      {required String msg,
      required String schemaPath,
      Map<String, dynamic>? payload}) {
    schemaPath = schemaPath.replaceFirst('#', '');
    _errors.add(StyleValidationError._(
        type: msg, schemaPath: schemaPath, payload: payload));
    if (!_reportMultipleErrors) throw FormatException(msg);
  }
}
