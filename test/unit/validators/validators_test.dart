import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/utils/validators.dart';

void main() {
  group('VA-01 to VA-04: Email & Password Validation', () {
    test('VA-01: Invalid email format rejected', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('missing@'), isNotNull);
      expect(Validators.email('@no-user.com'), isNotNull);
    });

    test('VA-01: Valid email accepted', () {
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('user.name+tag@domain.co.in'), isNull);
    });

    test('VA-02: Password < 8 chars rejected', () {
      expect(Validators.password('Ab1'), isNotNull);
      expect(Validators.password('Short1'), isNotNull);
    });

    test('VA-03: Password without uppercase rejected', () {
      expect(Validators.password('alllowercase1'), isNotNull);
    });

    test('VA-04: Password without number rejected', () {
      expect(Validators.password('NoNumberHere'), isNotNull);
    });

    test('Valid password accepted', () {
      expect(Validators.password('ValidPass1'), isNull);
      expect(Validators.password('Str0ngP@ss'), isNull);
    });
  });

  group('VA-05 to VA-07: Phone Number Validation', () {
    test('VA-05: Valid 10-digit Indian number accepted', () {
      expect(Validators.phoneNumber('9876543210'), isNull);
      expect(Validators.phoneNumber('6123456789'), isNull);
    });

    test('VA-05: Invalid phone numbers rejected', () {
      expect(Validators.phoneNumber('1234567890'), isNotNull); // starts with 1
      expect(Validators.phoneNumber('98765'), isNotNull); // too short
      expect(Validators.phoneNumber(''), isNotNull);
      expect(Validators.phoneNumber(null), isNotNull);
    });

    test('VA-06: +91 prefix normalized correctly', () {
      expect(Validators.normalizePhone('+919876543210'), equals('+919876543210'));
      expect(Validators.normalizePhone('919876543210'), equals('+919876543210'));
    });

    test('VA-07: 0 prefix normalized correctly', () {
      expect(Validators.normalizePhone('09876543210'), equals('+919876543210'));
    });

    test('Plain 10-digit number normalized', () {
      expect(Validators.normalizePhone('9876543210'), equals('+919876543210'));
    });
  });

  group('VA-08 to VA-10: OTP, Name, Rating Validation', () {
    test('VA-08: OTP must be exactly 6 digits', () {
      expect(Validators.otp('12345'), isNotNull);
      expect(Validators.otp('1234567'), isNotNull);
      expect(Validators.otp('abcdef'), isNotNull);
      expect(Validators.otp('123456'), isNull);
    });

    test('VA-09: Display name 2-50 characters', () {
      expect(Validators.displayName(''), isNotNull);
      expect(Validators.displayName('A'), isNotNull);
      expect(Validators.displayName('Jo'), isNull);
      expect(Validators.displayName('A' * 51), isNotNull);
      expect(Validators.displayName('Ravi'), isNull);
    });

    test('VA-10: Rating 1-5 range', () {
      expect(Validators.rating(0), isNotNull);
      expect(Validators.rating(6), isNotNull);
      expect(Validators.rating(null), isNotNull);
      expect(Validators.rating(1), isNull);
      expect(Validators.rating(5), isNull);
      expect(Validators.rating(3), isNull);
    });
  });
}
