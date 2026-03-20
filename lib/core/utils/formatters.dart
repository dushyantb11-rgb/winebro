import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String shortDate(DateTime date, {String? locale}) =>
      DateFormat('MMM d', locale).format(date);

  static String mediumDate(DateTime date, {String? locale}) =>
      DateFormat('MMM d, y', locale).format(date);

  static String longDate(DateTime date, {String? locale}) =>
      DateFormat('MMMM d, y', locale).format(date);

  static String number(num value, {String? locale}) =>
      NumberFormat('#,##0', locale).format(value);

  static String inr(double price, {String? locale}) =>
      '₹${NumberFormat('#,##0', locale).format(price)}';
}

