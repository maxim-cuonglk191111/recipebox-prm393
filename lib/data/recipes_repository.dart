import 'package:cloud_firestore/cloud_firestore.dart';

import '../logic/recipe.dart';

/// Thrown by [RecipesRepository.update] when a rename would collide with another recipe.
class DuplicateRecipeException implements Exception {
  @override
  String toString() => 'A recipe with the same name is already saved.';
}

class RecipesRepository {
  RecipesRepository([FirebaseFirestore? db])
      : _col = (db ?? FirebaseFirestore.instance).collection('recipes');

  final CollectionReference<Map<String, dynamic>> _col;

  Stream<List<Recipe>> watch(String uid) => _col
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map((d) => Recipe.fromDoc(d.id, d.data())).toList()..sort(compareRecipes));

  Map<String, dynamic> _data(String id, String uid, RecipeInput i, bool favorite, Object createdAt) => {
        'id': id,
        'userId': uid,
        'name': i.name,
        'category': i.category,
        'difficulty': i.difficulty,
        'cookTime': i.cookTime,
        'servings': i.servings,
        'favorite': favorite,
        'notes': i.notes,
        'createdAt': createdAt,
      };

  /// A transaction is used so nothing shows up locally before the server accepts the write.
  /// A duplicate name hits an existing document: the rules refuse it because createdAt would change.
  Future<void> add(String uid, RecipeInput i) {
    final id = recipeKey(uid, i.name);
    return _col.firestore.runTransaction((tx) async {
      tx.set(_col.doc(id), _data(id, uid, i, false, FieldValue.serverTimestamp()));
    });
  }

  Future<void> setFavorite(Recipe r, bool value) => _col.doc(r.id).update({'favorite': value});

  Future<void> delete(Recipe r) => _col.doc(r.id).delete();

  /// Returns the id of the saved recipe (it changes when the name changes the key).
  Future<String> update(Recipe old, RecipeInput i) async {
    final newId = recipeKey(old.userId, i.name);
    if (newId == old.id) {
      await _col.doc(old.id).update({
        'name': i.name,
        'category': i.category,
        'difficulty': i.difficulty,
        'cookTime': i.cookTime,
        'servings': i.servings,
        'notes': i.notes,
      });
      return old.id;
    }
    await _col.firestore.runTransaction((tx) async {
      final target = await tx.get(_col.doc(newId));
      if (target.exists) throw DuplicateRecipeException();
      tx.delete(_col.doc(old.id));
      tx.set(_col.doc(newId), _data(newId, old.userId, i, old.favorite, Timestamp.fromDate(old.createdAt!)));
    });
    return newId;
  }
}
