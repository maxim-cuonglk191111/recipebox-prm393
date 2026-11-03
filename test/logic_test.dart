import 'package:recipebox/logic/recipe.dart';
import 'package:recipebox/logic/recipe_filters.dart';
import 'package:recipebox/logic/recipe_validators.dart';
import 'package:flutter_test/flutter_test.dart';

Recipe r(String name, int time, {String c = 'Dinner', String d = 'Easy', bool fav = false, String notes = ''}) =>
    Recipe(id: name, userId: 'u', name: name, category: c, difficulty: d, cookTime: time, favorite: fav, notes: notes);

void main() {
  test('name / notes limits', () {
    expect(validateName('  '), 'Name is required');
    expect(validateName(''), 'Name is required');
    expect(validateName('a' * 80), isNull);
    expect(validateName('a' * 81), 'Name must be at most 80 characters');
    expect(validateNotes('a' * 300), isNull);
    expect(validateNotes('a' * 301), 'Notes must be at most 300 characters');
    expect(validateCategory(''), 'Please choose a category');
    expect(validateDifficulty(''), 'Please choose a difficulty');
  });

  test('cook time: required, whole number 1..600', () {
    expect(validateCookTime(''), 'Cook time is required');
    expect(validateCookTime('   '), 'Cook time is required');
    for (final ok in ['1', '25', '600', ' 30 ']) {
      expect(validateCookTime(ok), isNull, reason: ok);
    }
    for (final bad in ['0', '601', '-1', '2.5', 'abc', '1e2', '٣']) {
      expect(validateCookTime(bad), cookTimeError, reason: bad);
    }
  });

  test('servings: optional, whole number 1..20', () {
    for (final ok in ['', ' ', '1', '20', '4']) {
      expect(validateServings(ok), isNull, reason: ok);
    }
    for (final bad in ['0', '21', '-1', '2.5', 'x']) {
      expect(validateServings(bad), servingsError, reason: bad);
    }
  });

  test('sort: cook time first, equal times by name (case-insensitive)', () {
    final l = [r('zeta', 20), r('Alpha', 20), r('Quick', 5), r('Slow', 120), r('beta', 20)]..sort(compareRecipes);
    expect(l.map((e) => e.name), ['Quick', 'Alpha', 'beta', 'zeta', 'Slow']);
  });

  test('recipe key ignores case, trims, escapes slash, is per user', () {
    expect(recipeKey('u', 'Pho Bo'), recipeKey('u', ' pho bo '));
    expect(recipeKey('u', 'Pho Bo'), isNot(recipeKey('v', 'Pho Bo')));
    expect(recipeKey('u', 'a/b').contains('/'), isFalse);
    expect(recipeKey('u', 'Phở Bò'), 'u|phở bò'); // ASCII-only lower-casing, like the rules
  });

  test('filters combine; search covers name and notes, trimmed, case-insensitive', () {
    final all = [
      r('Pancakes', 20, c: 'Breakfast', d: 'Easy', fav: true, notes: 'with maple syrup'),
      r('Lasagna', 90, c: 'Dinner', d: 'Hard', notes: 'Family recipe'),
      r('Tiramisu', 30, c: 'Dessert', d: 'Medium', fav: true),
    ];
    List<String> run(RecipeFilters f) => all.where(f.matches).map((e) => e.name).toList();
    expect(run(const RecipeFilters(category: 'Dessert')), ['Tiramisu']);
    expect(run(const RecipeFilters(difficulty: 'Hard')), ['Lasagna']);
    expect(run(const RecipeFilters(favoritesOnly: true)), ['Pancakes', 'Tiramisu']);
    expect(run(const RecipeFilters(query: '  MAPLE ')), ['Pancakes']);
    expect(run(const RecipeFilters(query: 'family')), ['Lasagna']);
    expect(run(const RecipeFilters(query: 'pan')), ['Pancakes']);
    expect(run(const RecipeFilters(favoritesOnly: true, difficulty: 'Medium', query: 'tira')), ['Tiramisu']);
    expect(run(const RecipeFilters(favoritesOnly: true, category: 'Dinner')), isEmpty);
  });

  test('summary: counts, favorites, total time, category order (ties: Breakfast, Lunch, Dinner, Dessert)', () {
    final s = summarize([
      r('a', 10, c: 'Dessert', fav: true),
      r('b', 20, c: 'Lunch'),
      r('c', 30, c: 'Breakfast'),
      r('d', 40, c: 'Dessert'),
    ]);
    expect(s.total, 4);
    expect(s.favorites, 1);
    expect(s.totalTime, 100);
    expect(s.byCategory.map((e) => '${e.key}:${e.value}'), ['Dessert:2', 'Breakfast:1', 'Lunch:1']);
    final empty = summarize([]);
    expect([empty.total, empty.favorites, empty.totalTime, empty.byCategory.length], [0, 0, 0, 0]);
  });
}
