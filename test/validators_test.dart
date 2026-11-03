import 'package:bookshelf/logic/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth messages', () {
    expect(validateEmail(''), 'Email is required');
    expect(validateEmail('abc'), 'Please enter a valid email address');
    expect(validateEmail('a@b.co'), isNull);
    expect(validatePassword(''), 'Password is required');
    expect(validatePassword('123'), isNull);
    expect(validatePassword('123', requireMinLength: true), 'Password must be at least 6 characters');
    expect(validateConfirmPassword('', 'x'), 'Confirm password is required');
    expect(validateConfirmPassword('y', 'x'), 'Passwords do not match');
  });
}
