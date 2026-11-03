import 'package:cloud_firestore/cloud_firestore.dart';

const categories = ['Breakfast', 'Lunch', 'Dinner', 'Dessert'];
const difficulties = ['Easy', 'Medium', 'Hard'];

class Recipe {
  const Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.cookTime,
    this.servings,
    this.favorite = false,
    this.notes = '',
    this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String category;
  final String difficulty;
  final int cookTime;
  final int? servings;
  final bool favorite;
  final String notes;
  final DateTime? createdAt;

  /// Defensive read: a missing or odd field degrades instead of crashing.
  factory Recipe.fromDoc(String id, Map<String, dynamic> d) {
    final t = d['cookTime'];
    final s = d['servings'];
    final c = d['createdAt'];
    return Recipe(
      id: id,
      userId: (d['userId'] ?? '') as String,
      name: (d['name'] ?? '') as String,
      category: (d['category'] ?? '') as String,
      difficulty: (d['difficulty'] ?? '') as String,
      cookTime: t is num ? t.toInt() : 0,
      servings: s is num ? s.toInt() : null,
      favorite: d['favorite'] == true,
      notes: (d['notes'] ?? '') as String,
      createdAt: c is Timestamp ? c.toDate() : null,
    );
  }
}

/// What the Add / Edit form produces (already trimmed and parsed).
class RecipeInput {
  const RecipeInput({
    required this.name,
    required this.category,
    required this.difficulty,
    required this.cookTime,
    this.servings,
    this.notes = '',
  });

  final String name;
  final String category;
  final String difficulty;
  final int cookTime;
  final int? servings;
  final String notes;
}

/// Document id: one recipe per (user, name), letter case ignored.
/// MUST stay identical to `recipeKey` in firestore.rules. Security Rules `lower()` only
/// lower-cases ASCII letters, so this does the same (verified against the live rules).
String recipeKey(String userId, String name) {
  final n = name
      .trim()
      .replaceAllMapped(RegExp('[A-Z]'), (m) => m[0]!.toLowerCase())
      .replaceAll('/', '%2F');
  return '$userId|$n';
}

/// Cook time (shortest first), equal cook times by name (case-insensitive).
int compareRecipes(Recipe a, Recipe b) {
  final c = a.cookTime.compareTo(b.cookTime);
  if (c != 0) return c;
  final n = a.name.toLowerCase().compareTo(b.name.toLowerCase());
  return n != 0 ? n : a.id.compareTo(b.id);
}
