import 'package:flutter_test/flutter_test.dart';
import 'package:edu_auth/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns null for valid email',   () => expect(Validators.email('a@b.com'), isNull));
    test('returns error for empty',        () => expect(Validators.email(''), isNotNull));
    test('returns error for missing @',    () => expect(Validators.email('notanemail'), isNotNull));
    test('returns error for missing TLD',  () => expect(Validators.email('a@b'), isNotNull));
  });

  group('Validators.password', () {
    test('null for strong password',       () => expect(Validators.password('Strong@1'), isNull));
    test('error for too short',            () => expect(Validators.password('Ab@1'), isNotNull));
    test('error for no uppercase',         () => expect(Validators.password('weak@123'), isNotNull));
    test('error for no number',            () => expect(Validators.password('Weak@abc'), isNotNull));
    test('error for no special char',      () => expect(Validators.password('Weak1234'), isNotNull));
  });

  group('Validators.passwordStrength', () {
    test('score 0 for empty',   () => expect(Validators.passwordStrength(''), 0));
    test('score 4 for strong',  () => expect(Validators.passwordStrength('Strong@1'), 4));
    test('score 1 for length only', () => expect(Validators.passwordStrength('password'), 1));
  });

  group('Validators.teacherCode', () {
    test('null for valid 8-char code', () => expect(Validators.teacherCode('TCH12345'), isNull));
    test('error for short code',       () => expect(Validators.teacherCode('TCH1'), isNotNull));
    test('error for empty',            () => expect(Validators.teacherCode(''), isNotNull));
  });

  group('Validators.otp', () {
    test('null for valid 6-digit OTP',  () => expect(Validators.otp('123456'), isNull));
    test('error for 5 digits',          () => expect(Validators.otp('12345'), isNotNull));
    test('error for letters',           () => expect(Validators.otp('abc123'), isNotNull));
  });
}
