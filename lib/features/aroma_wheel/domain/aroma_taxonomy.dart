import 'package:winebro/core/config/app_config.dart';

class AromaCategory {
  const AromaCategory({
    required this.name,
    required this.color,
    required this.subcategories,
  });

  final String name;
  final int color;
  final List<AromaSubcategory> subcategories;

  List<String> get allAromas =>
      subcategories.expand((s) => s.aromas).toList();
}

class AromaSubcategory {
  const AromaSubcategory({
    required this.name,
    required this.aromas,
  });

  final String name;
  final List<String> aromas;
}

/// The aroma wheel (families → sub-families → aromas), from
/// `config/aromaWheel`.
List<AromaCategory> get kAromaWheel => AppConfig.current.aromaWheel.categories;
