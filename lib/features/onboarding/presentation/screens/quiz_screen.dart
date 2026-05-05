import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/features/onboarding/domain/quiz_engine.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/onboarding/presentation/providers/quiz_provider.dart';
import 'package:winebro/shared/widgets/palate_radar_chart.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _step = 0;
  final _selectedFoods = <String>{};
  String? _selectedChaat;
  String? _selectedDrink;
  final _sliders = <PalateAxis, double>{
    for (final axis in PalateAxis.values) axis: 5.0,
  };
  bool _showResult = false;
  PalateProfile? _generatedProfile;

  bool get _showChaatStep =>
      _selectedFoods.contains('pani-puri');

  int get _totalSteps => _showChaatStep ? 4 : 3;

  int get _adjustedStep {
    if (!_showChaatStep && _step >= 1) return _step + 1;
    return _step;
  }

  bool get _canProceed => switch (_step) {
    0 => _selectedFoods.isNotEmpty && _selectedFoods.length <= 2,
    1 when _showChaatStep => _selectedChaat != null,
    1 when !_showChaatStep => _selectedDrink != null,
    2 when _showChaatStep => _selectedDrink != null,
    2 when !_showChaatStep => true,
    3 => true,
    _ => false,
  };

  void _next() {
    if (_step < _totalSteps) {
      setState(() => _step++);
    } else {
      _generateProfile();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _generateProfile() {
    final engine = const QuizEngine();
    final foodAnswers = kQuizStep1Foods.where((a) => _selectedFoods.contains(a.id)).toList();
    final chaatAnswer = _selectedChaat != null ? kQuizStep2Chaat.firstWhere((a) => a.id == _selectedChaat) : null;
    final drinkAnswer = kQuizStep3Drinks.firstWhere((a) => a.id == _selectedDrink);
    _generatedProfile = engine.generateProfile(foodAnswers: foodAnswers, chaatAnswer: chaatAnswer, drinkAnswer: drinkAnswer, sliderOverrides: _sliders);
    setState(() => _showResult = true);
  }

  Future<void> _finish() async {

    await ref.read(quizProfileProvider.notifier).saveProfile(_generatedProfile!);
    await ref.read(authStateProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    if (_showResult) {
      return _buildResultScreen(context, colors, l10n);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.charcoal, colors.charcoalDeep],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_step > 0)
                          IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: colors.textSecondary),
                            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                            onPressed: _back,
                          ),
                        const Spacer(),
                        Text(
                          l10n.stepOf(_step + 1, _totalSteps + 1),
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: (_step + 1) / (_totalSteps + 1),
                        minHeight: 3,
                        backgroundColor: colors.surface2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.paprika,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _buildStep(colors, l10n),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(28),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _next : null,
                    child: Text(
                      _step == _totalSteps ? l10n.seeMyProfile : l10n.nextButton,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AppColors colors, AppLocalizations l10n) {
    final logicalStep = _adjustedStep;

    return switch (logicalStep) {
      0 => _buildFoodStep(colors, l10n),
      1 => _buildChaatStep(colors, l10n),
      2 => _buildDrinkStep(colors, l10n),
      3 => _buildSliderStep(colors, l10n),
      _ => const SizedBox(),
    };
  }

  Widget _buildFoodStep(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quizFoodQuestion,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.pickUpTo2,
          style: TextStyle(color: colors.textTertiary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: kQuizStep1Foods.map((answer) {
            final isSelected = _selectedFoods.contains(answer.id);
            return _QuizOption(
              label: answer.label,
              emoji: answer.icon,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedFoods.remove(answer.id);
                  } else if (_selectedFoods.length < 2) {
                    _selectedFoods.add(answer.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChaatStep(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chaatQuestion,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        ...kQuizStep2Chaat.map((answer) {
          final isSelected = _selectedChaat == answer.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _QuizOption(
              label: answer.label,
              emoji: answer.icon,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedChaat = answer.id),
              fullWidth: true,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDrinkStep(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.drinkQuestion,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        ...kQuizStep3Drinks.map((answer) {
          final isSelected = _selectedDrink == answer.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _QuizOption(
              label: answer.label,
              emoji: answer.icon,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedDrink = answer.id),
              fullWidth: true,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSliderStep(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.fineTunePalate,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.adjustSliders,
          style: TextStyle(color: colors.textTertiary, fontSize: 13),
        ),
        const SizedBox(height: 32),
        _buildSlider(colors, PalateAxis.fruit, l10n.sliderDry, l10n.sliderSweet),
        _buildSlider(colors, PalateAxis.acidity, l10n.sliderSmooth, l10n.sliderTangy),
        _buildSlider(colors, PalateAxis.body, l10n.sliderLight, l10n.sliderRich),
        _buildSlider(colors, PalateAxis.tannin, l10n.sliderMild, l10n.sliderFiery),
      ],
    );
  }

  Widget _buildSlider(
    AppColors colors,
    PalateAxis axis,
    String lowLabel,
    String highLabel,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                axis.displayName,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                _sliders[axis]!.round().toString(),
                style: TextStyle(
                  color: colors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: colors.paprika,
              inactiveTrackColor: colors.surface3,
              thumbColor: colors.paprikaLight,
              overlayColor: colors.paprika.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _sliders[axis]!,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) => setState(() => _sliders[axis] = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lowLabel,
                style: TextStyle(color: colors.textTertiary, fontSize: 11),
              ),
              Text(
                highLabel,
                style: TextStyle(color: colors.textTertiary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, AppColors colors, AppLocalizations l10n) {
    final profile = _generatedProfile!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.charcoal, colors.charcoalDeep],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  l10n.yourPalateProfile,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),

                PalateRadarChart(profile: profile),
                const SizedBox(height: 24),

                Icon(
                  profile.archetype.icon,
                  size: 48,
                  color: colors.gold,
                ),
                const SizedBox(height: 12),
                Text(
                  profile.archetype.displayName,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.archetype.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _finish,
                    child: Text(l10n.letsGoBro),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    this.fullWidth = false,
  });

  final String label;
  final IconData emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: fullWidth ? 16 : 12,
          vertical: fullWidth ? 14 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.paprika.withValues(alpha: 0.15)
              : colors.surface1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colors.paprika : colors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(emoji, size: 20, color: isSelected ? colors.paprikaLight : colors.textTertiary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colors.textPrimary
                      : colors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

