part of style_object;

class DataRead<T> {
  DataRead({required this.data, required this.offset});

  T data;

  int offset;
}

abstract class StyleData<T> {
  StyleData(this.value);

  factory StyleData.create(Object? value) {
    if (value is StyleData) {
      return value as StyleData<T>;
    } else if (value is int) {
      return IntData(value) as StyleData<T>;
    } else if (value is bool) {
      return BoolData(value) as StyleData<T>;
    } else if (value is String) {
      return StringData(value) as StyleData<T>;
    } else if (value is Map) {
      if (value is Map<int, StyleData>) {
        return StyleObjectWithKeys(value) as StyleData<T>;
      } else if (value is Map<String, StyleData>) {
        throw UnimplementedError();
      }
    } else if (value is List) {
      if (value is List<int>) {
        return Int64ListData(value) as StyleData<T>;
      } else if (value is List<double>) {
        //TODO:
        throw UnimplementedError();
      } else {
        return ListData(value) as StyleData<T>;
      }
    }

    throw 0;
  }

  T value;

  //late StyleKey key;

  int getLength(KeyFactory<T> key);

  WriteMeta write(
      ByteData byteData, int offset, KeyFactory<T> key, bool withKey);

  KeyFactory createKey(int key);
}
