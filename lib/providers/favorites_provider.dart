import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<int> _favoriteIds = [];
  final String _prefsKey = 'favorite_pokemon_ids';

  List<int> get favoriteIds => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedKeys = prefs.getStringList(_prefsKey);
    
    if (savedKeys != null) {
      _favoriteIds.addAll(savedKeys.map((e) => int.parse(e)));
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    
    await prefs.setStringList(_prefsKey, _favoriteIds.map((e) => e.toString()).toList());
    notifyListeners();
  }

  bool isFavorite(int id) {
    return _favoriteIds.contains(id);
  }
}
