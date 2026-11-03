/// Validation messages are exactly the texts required by the exam.
final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateEmail(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Email is required';
  if (!_emailRe.hasMatch(s)) return 'Please enter a valid email address';
  return null;
}

/// [requireMinLength] is true on Register only.
String? validatePassword(String? v, {bool requireMinLength = false}) {
  final s = v ?? '';
  if (s.isEmpty) return 'Password is required';
  if (requireMinLength && s.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validateConfirmPassword(String? v, String password) {
  final s = v ?? '';
  if (s.isEmpty) return 'Confirm password is required';
  if (s != password) return 'Passwords do not match';
  return null;
}

String? validateTitle(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Title is required';
  if (s.length > 100) return 'Title must be at most 100 characters';
  return null;
}

String? validateAuthor(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Author is required';
  if (s.length > 60) return 'Author must be at most 60 characters';
  return null;
}

String? validateGenre(String? v) =>
    (v == null || v.isEmpty) ? 'Please choose a genre' : null;

String? validateStatus(String? v) =>
    (v == null || v.isEmpty) ? 'Please choose a status' : null;

const ratingError = 'Rating must be a whole number from 0 to 5';

/// Optional: empty (or spaces only) is fine; otherwise digits only, 0..5.
String? validateRating(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return null;
  if (!RegExp(r'^\d+$').hasMatch(s)) return ratingError;
  final n = int.parse(s);
  return n > 5 ? ratingError : null;
}

String? validateNotes(String? v) =>
    (v ?? '').length > 300 ? 'Notes must be at most 300 characters' : null;
