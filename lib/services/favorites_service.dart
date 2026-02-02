import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';

class FavoritesService {
  static const String key = 'favorites';

  Future<void> addFavorite(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    if (!list.any((e) => jsonDecode(e)['id'] == place.id)) {
      list.add(jsonEncode(place.toJson()));
      await prefs.setStringList(key, list);
    }
  }

  Future<void> removeFavorite(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    list.removeWhere((e) => jsonDecode(e)['id'] == place.id);
    await prefs.setStringList(key, list);
  }

  Future<List<Place>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    return list.map((e) => Place.fromJson(jsonDecode(e))).toList();
  }
}
