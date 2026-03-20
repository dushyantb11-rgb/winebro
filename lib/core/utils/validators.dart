
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }
    return null;
  }

  static String _stripPhone(String raw) =>
      raw.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = _stripPhone(value);
    final digits = cleaned.startsWith('91') && cleaned.length == 12
        ? cleaned.substring(2)
        : cleaned;
    if (digits.length != 10) {
      return 'Enter a 10-digit phone number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    if (value.trim().length != 6 || !RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter a 6-digit OTP';
    }
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be under 50 characters';
    }
    return null;
  }

  static String? rating(int? value) {
    if (value == null || value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }
    return null;
  }

  static String normalizePhone(String raw) {
    final cleaned = _stripPhone(raw);
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    }
    if (cleaned.startsWith('0')) return '+91${cleaned.substring(1)}';
    return '+91$cleaned';
  }
}

