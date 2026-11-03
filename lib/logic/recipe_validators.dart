// Messages are exactly the texts required by the exam.

String? validateName(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Name is required';
  if (s.length > 80) return 'Name must be at most 80 characters';
  return null;
}

String? validateCategory(String? v) =>
    (v == null || v.isEmpty) ? 'Please choose a category' : null;

String? validateDifficulty(String? v) =>
    (v == null || v.isEmpty) ? 'Please choose a difficulty' : null;

const cookTimeError = 'Cook time must be a whole number from 1 to 600';

/// Required: whole number 1..600 (digits only).
String? validateCookTime(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Cook time is required';
  if (!RegExp(r'^\d+$').hasMatch(s)) return cookTimeError;
  final n = int.parse(s);
  return (n < 1 || n > 600) ? cookTimeError : null;
}

const servingsError = 'Servings must be a whole number from 1 to 20';

/// Optional: empty (or spaces only) is fine; otherwise digits only, 1..20.
String? validateServings(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return null;
  if (!RegExp(r'^\d+$').hasMatch(s)) return servingsError;
  final n = int.parse(s);
  return (n < 1 || n > 20) ? servingsError : null;
}

String? validateNotes(String? v) =>
    (v ?? '').length > 300 ? 'Notes must be at most 300 characters' : null;
