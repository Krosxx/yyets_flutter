import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

///
/// 本地存储，适配Windows
///
///
///

_MySp _ins;

Future<_MySp> get MySp async {
  if (_ins == null) {
    _ins = _MySp();
    await _ins.init();
  }
  return _ins;
}

class _MySp {
  static SharedPreferences _sp;
  bool isWin = false;

  get sp => _sp;

  init() async {
    if (_sp != null) return;
    try {
      isWin = Platform.isWindows;
    } catch (e) {
      isWin = false;
    }
    try {
      if (isWin) {
        _initFile();
      } else {
        _sp = await SharedPreferences.getInstance();
      }
    } catch (e) {
      _sp = await SharedPreferences.getInstance();
    }
  }

  has(String key) {
    if (isWin) {
      return _configMap.containsKey(key);
    } else {
      return _sp.getKeys().contains(key);
    }
  }

  remove(String key) {
    if (isWin) {
      _configMap.remove(key);
      _toFile();
    } else {
      _sp.remove(key);
    }
  }

  dynamic get(String key, [defaultValue]) {
    if (isWin) {
      return _getWindows(key, defaultValue: defaultValue);
    } else {
      return _getMobile(key, defaultValue: defaultValue);
    }
  }

  dynamic _getMobile(String key, {defaultValue}) {
    if (sp.getKeys().contains(key)) {
      return sp.get(key);
    } else {
      return defaultValue;
    }
  }

  dynamic _getWindows(String key, {defaultValue}) {
    return _configMap[key] ?? defaultValue;
  }

  set(String key, value, {bool encrypt = false}) async {
    if (encrypt && value.runtimeType != String) {
      throw Exception("不支持String外类型加密");
    }
    if (isWin) {
      //
      _setOnWindows(key, value, encrypt: encrypt);
      return;
    } else {
      _setOnMobile(key, value, encrypt: encrypt);
    }
  }

  void _setOnMobile(String key, value, {encrypt}) {
    if (value == null) {
      _sp.remove(key);
      return;
    }
    switch (value.runtimeType) {
      case String:
        sp.setString(key, value);
        break;
      case int:
        sp.setInt(key, value);
        break;
      case bool:
        sp.setBool(key, value);
        break;
      case List:
        sp.setStringList(key, value);
        break;
      default:
        var json = jsonEncode(value);
        sp.setString(key, json);
    }
  }

  static _setOnWindows(String key, value, {encrypt}) {
    if (value == null) {
      _configMap.remove(key);
    } else {
      if (encrypt) {
        throw Exception("未完成加密功能");
      } else {
        switch (value.runtimeType) {
          case String:
          case int:
          case bool:
            _configMap[key] = value;
            break;
          default:
            var json = jsonEncode(value);
            _configMap[key] = json;
        }
      }
    }
    _toFile();
  }

  static Map _configMap;

  static _toFile() {
    var json = jsonEncode(_configMap);
//    print("写配置: " + json);
    var f = File("config");
    f.writeAsStringSync(json);
  }

  static _initFile() {
    if (_configMap != null) return;

    var configFile = File("config");
    if (!configFile.existsSync()) {
      configFile.createSync();
      configFile.writeAsStringSync("{}");
      _configMap = new Map();
    } else {
      //文件存在
      var json = configFile.readAsStringSync();
//      print("配置文件：" + json);
      try {
        _configMap = jsonDecode(json);
      } catch (e) {
        _configMap = {};
        configFile.writeAsStringSync("{}");
      }
    }
  }

  String encrypt(data) {
    return data;
  }

  String decrypt(data) {
    return data;
  }
}
