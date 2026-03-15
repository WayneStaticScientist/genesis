import 'package:flutter/material.dart';

extension BoolUtils on bool {
  String lors(String s, String t) {
    return (this) ? s : t;
  }

  MaterialColor lorc(MaterialColor s, MaterialColor t) {
    return (this) ? s : t;
  }

  T lord<T>(T s, T t) {
    return (this) ? s : t;
  }
}
