import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';


class PalateRadarChart extends StatelessWidget {
  const PalateRadarChart({
    required this.profile,
    this.height = 260,
    super.key,
  });

  final PalateProfile profile;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: height,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              dataEntries: PalateAxis.values
                  .map((a) => RadarEntry(value: profile[a]))
                  .toList(),
              borderColor: colors.paprika,
              fillColor: colors.paprika.withValues(alpha: 0.25),
              borderWidth: 2,
              entryRadius: 4,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData:
              BorderSide(color: colors.borderDefault, width: 0.5),
          gridBorderData:
              BorderSide(color: colors.borderSubtle, width: 0.5),
          tickCount: 5,
          ticksTextStyle: const TextStyle(fontSize: 0),
          tickBorderData:
              BorderSide(color: colors.borderSubtle, width: 0.3),
          titleTextStyle: TextStyle(
            color: colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          getTitle: (index, _) => RadarChartTitle(
            text: PalateAxis.values[index].displayName,
          ),
          titlePositionPercentageOffset: 0.15,
        ),
      ),
    );
  }
}
