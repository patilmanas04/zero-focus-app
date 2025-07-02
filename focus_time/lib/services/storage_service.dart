import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';

class StorageService {
  static const String _key = 'focus_sessions';

  static Future<List<SessionModel>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);

    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList
        .map((item) => SessionModel.fromJson(item))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> saveSession(SessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final List<SessionModel> current = await getSessions();
    current.add(session);

    final String updatedData = jsonEncode(
      current.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_key, updatedData);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
