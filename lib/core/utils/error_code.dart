import 'package:firebase_core/firebase_core.dart';

/// Short, non-sensitive code for an error, shown to testers so a field
/// report names the real cause (e.g. `permission-denied`, `unavailable`).
String errorCode(Object error) => switch (error) {
      FirebaseException(:final code) => code,
      FormatException() => 'bad-data',
      TypeError() => 'bad-data',
      _ => error.runtimeType.toString(),
    };
