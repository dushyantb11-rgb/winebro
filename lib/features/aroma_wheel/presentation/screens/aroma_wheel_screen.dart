import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/aroma_wheel/domain/aroma_taxonomy.dart';
import 'package:winebro/features/aroma_wheel/presentation/aroma_calibration_sheet.dart';

class AromaWheelScreen extends StatefulWidget {
  const AromaWheelScreen({super.key});

  @override
  State<AromaWheelScreen> createState() => _AromaWheelScreenState();
}

class _AromaWheelScreenState extends State<AromaWheelScreen> {
  int? _selectedCategoryIndex;
  int? _selectedSubIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aromaExplorerTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (_selectedSubIndex != null) {
              setState(() => _selectedSubIndex = null);
            } else if (_selectedCategoryIndex != null) {
              setState(() => _selectedCategoryIndex = null);
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          if (_selectedCategoryIndex == null)
            TextButton.icon(
              onPressed: () => AromaCalibrationSheet.show(context),
              icon: Icon(Icons.tune, color: colors.paprika, size: 18),
              label: Text(
                l10n.aromaCalibrationCta,
                style: TextStyle(
                  color: colors.paprika,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedCategoryIndex == null
            ? _buildCategoryWheel(colors, l10n)
            : _selectedSubIndex == null
                ? _buildSubcategories(colors, l10n)
                : _buildAromas(colors),
      ),
    );
  }

  Widget _buildCategoryWheel(AppColors colors, AppLocalizations l10n) {
    return Padding(
      key: const ValueKey('categories'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.broAromaWheel,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tapCategoryToExplore,
            style: TextStyle(color: colors.textTertiary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: kAromaWheel.length,
              itemBuilder: (context, index) {
                final cat = kAromaWheel[index];
                final color = Color(cat.color);
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategoryIndex = index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat.name,
                          style: TextStyle(
                            color: color,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.groupsAndAromas(cat.subcategories.length, cat.allAromas.length),
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategories(AppColors colors, AppLocalizations l10n) {
    final cat = kAromaWheel[_selectedCategoryIndex!];
    final color = Color(cat.color);

    return Padding(
      key: ValueKey('sub-${cat.name}'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cat.name,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tapToExploreAromas,
            style: TextStyle(color: colors.textTertiary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: cat.subcategories.length,
              itemBuilder: (context, index) {
                final sub = cat.subcategories[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedSubIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface1,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.name,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sub.aromas.join(', '),
                                style: TextStyle(
                                  color: colors.textTertiary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: colors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAromas(AppColors colors) {
    final cat = kAromaWheel[_selectedCategoryIndex!];
    final sub = cat.subcategories[_selectedSubIndex!];
    final color = Color(cat.color);

    return Padding(
      key: ValueKey('aromas-${sub.name}'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sub.name,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            cat.name,
            style: TextStyle(color: colors.textTertiary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: sub.aromas.map((aroma) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    aroma,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

