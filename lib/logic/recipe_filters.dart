import 'recipe.dart';

class RecipeFilters {
  const RecipeFilters({
    this.category,
    this.difficulty,
    this.favoritesOnly = false,
    this.query = '',
  });

  /// null = All.
  final String? category;
  final String? difficulty;
  final bool favoritesOnly;
  final String query;

  RecipeFilters copyWith({
    String? category,
    String? difficulty,
    bool? favoritesOnly,
    String? query,
    bool clearCategory = false,
    bool clearDifficulty = false,
  }) =>
      RecipeFilters(
        category: clearCategory ? null : (category ?? this.category),
        difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
        favoritesOnly: favoritesOnly ?? this.favoritesOnly,
        query: query ?? this.query,
      );

  bool matches(Recipe r) {
    if (category != null && r.category != category) return false;
    if (difficulty != null && r.difficulty != difficulty) return false;
    if (favoritesOnly && !r.favorite) return false;
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty && !r.name.toLowerCase().contains(q) && !r.notes.toLowerCase().contains(q)) {
      return false;
    }
    return true;
  }
}

class RecipeSummary {
  const RecipeSummary(this.total, this.favorites, this.totalTime, this.byCategory);
  final int total;
  final int favorites;
  final int totalTime;

  /// One entry per category that appears; most recipes first, ties in
  /// Breakfast, Lunch, Dinner, Dessert order.
  final List<MapEntry<String, int>> byCategory;
}

RecipeSummary summarize(List<Recipe> shown) {
  final counts = <String, int>{};
  var time = 0;
  for (final r in shown) {
    counts[r.category] = (counts[r.category] ?? 0) + 1;
    time += r.cookTime;
  }
  final rows = counts.entries.toList()
    ..sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : categories.indexOf(a.key).compareTo(categories.indexOf(b.key));
    });
  return RecipeSummary(shown.length, shown.where((r) => r.favorite).length, time, rows);
}
