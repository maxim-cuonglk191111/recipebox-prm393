import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../logic/recipe.dart';
import '../logic/recipe_filters.dart';
import 'recipes_repository.dart';

/// Single source of truth for the signed-in user's recipes and the list filters.
class RecipesController extends ChangeNotifier {
  RecipesController([RecipesRepository? repo]) : _repo = repo ?? RecipesRepository();

  final RecipesRepository _repo;
  StreamSubscription<List<Recipe>>? _sub;
  String? _uid;

  List<Recipe> _all = const [];
  bool loading = false;
  String? loadError;
  RecipeFilters filters = const RecipeFilters();

  String? get uid => _uid;
  List<Recipe> get all => _all;
  List<Recipe> get shown => _all.where(filters.matches).toList();
  RecipeSummary get summary => summarize(shown);
  Recipe? byId(String id) {
    for (final r in _all) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Called when the signed-in user changes; drops everything of the previous user.
  void bind(String? uid) {
    if (uid == _uid) return;
    _sub?.cancel();
    _sub = null;
    _uid = uid;
    _all = const [];
    filters = const RecipeFilters();
    loadError = null;
    loading = uid != null;
    if (uid != null) {
      _sub = _repo.watch(uid).listen((list) {
        _all = list;
        loading = false;
        loadError = null;
        notifyListeners();
      }, onError: (Object e) {
        loading = false;
        loadError = _message(e);
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void setFilters(RecipeFilters f) {
    filters = f;
    notifyListeners();
  }

  void clearFilters() => setFilters(const RecipeFilters());

  /// Returns null on success, otherwise the error message to show on the form.
  Future<String?> add(RecipeInput input) => _run(() => _repo.add(_uid!, input));

  Future<String?> update(String id, RecipeInput input) {
    final old = byId(id);
    if (old == null) return Future.value('This recipe no longer exists.');
    return _run(() => _repo.update(old, input));
  }

  Future<String?> setFavorite(Recipe r) => _run(() => _repo.setFavorite(r, !r.favorite));

  Future<String?> delete(Recipe r) => _run(() => _repo.delete(r));

  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } catch (e) {
      return _message(e);
    }
  }

  /// Firestore's own message. On web the exception arrives wrapped in a string such as
  /// "Dart exception: [cloud_firestore/permission-denied] Missing or insufficient permissions."
  static String _message(Object e) {
    if (e is FirebaseException) return e.message ?? e.code;
    final m = RegExp(r'\[[\w-]+/[\w-]+\]\s*(.*)').firstMatch(e.toString());
    return m?.group(1) ?? e.toString();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
