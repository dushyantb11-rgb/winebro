import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_elevation.dart';
import 'package:winebro/core/theme/app_motion.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/core/utils/formatters.dart';
import 'package:winebro/features/aroma_wheel/domain/aroma_taxonomy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:winebro/features/journal/data/brocard_photo_service.dart';
import 'package:winebro/features/journal/domain/journal_context.dart';
import 'package:winebro/features/journal/domain/journal_entry.dart';
import 'package:winebro/features/journal/presentation/widgets/occasion_chips.dart';
import 'package:winebro/features/journal/presentation/widgets/quick_log_sheet.dart';
import 'package:winebro/features/profile/data/gamification_service.dart';
import 'package:winebro/shared/widgets/hero_photo_card.dart';
import 'package:winebro/shared/widgets/segmented_chip_selector.dart';
import 'package:winebro/shared/widgets/star_rating.dart';

final journalEntriesProvider =
    StreamProvider<List<JournalEntry>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('journal')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => JournalEntry.fromMap(doc.data()))
          .toList());
});

/// Redesigned 2026 Journal.
///
/// Three blocks:
///   1. Hero stat strip — N Tastings · N Wines · N Spirits with
///      ticker count animation on first load
///   2. Filter chips — All / Wine / Whisky / Gin / Rum / Beer
///   3. BroCard timeline — full-width cards, score badge right,
///      compact metadata, tap → detail (future v1.1)
///
/// Empty state: full-bleed cinematic gradient + "Start your tasting story"
/// + dual CTA (Scan a bottle / Pick from popular wines). Beautiful, not
/// apologetic.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  String _filter = 'All';
  static const _filterOptions = ['All', 'Wine', 'Spirits', 'Beer', 'Cocktails'];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final entries = ref.watch(journalEntriesProvider);

    return Scaffold(
      body: SafeArea(
        child: entries.when(
          loading: () => Center(child: CircularProgressIndicator(color: colors.paprika)),
          error: (e, _) => Center(
            child: Text(l10n.errorLoadingJournal, style: TextStyle(color: colors.error)),
          ),
          data: (items) {
            if (items.isEmpty) return _EmptyState();

            final filtered = _filter == 'All'
                ? items
                : items
                    .where((e) =>
                        e.category.toLowerCase().contains(_filter.toLowerCase()))
                    .toList();

            final stats = _Stats.from(items);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      context.l10n.journalTitleHero,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Text(
                      context.l10n.journalByline,
                      style: context.serifQuote
                          .copyWith(color: colors.textSecondary),
                    ),
                  ),
                ),

                // Hero stats
                SliverToBoxAdapter(child: _HeroStats(stats: stats)),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Filter pills
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: _filterOptions.map((opt) {
                        final active = _filter == opt;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _filter = opt);
                            },
                            child: AnimatedContainer(
                              duration: AppMotion.fast,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: active
                                    ? colors.paprika
                                    : colors.surface1,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: active
                                      ? colors.paprika
                                      : colors.borderDefault,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? colors.inkOnHero
                                        : colors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // BroCard timeline
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _BroCardTimelineRow(entry: filtered[index]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            QuickLogSheet.show(context);
          },
          backgroundColor: colors.paprika,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(context.l10n.journalNewBroCard,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ============================================================
// Hero stats — three numbers with ticker animation
// ============================================================

class _Stats {
  const _Stats({required this.total, required this.wines, required this.spirits});
  final int total;
  final int wines;
  final int spirits;

  factory _Stats.from(List<JournalEntry> entries) {
    final wines = entries.where((e) => e.category.toLowerCase().contains('wine')).length;
    final spirits = entries.where((e) {
      final c = e.category.toLowerCase();
      return c.contains('whisky') ||
          c.contains('gin') ||
          c.contains('rum') ||
          c.contains('vodka') ||
          c.contains('tequila') ||
          c.contains('spirits');
    }).length;
    return _Stats(total: entries.length, wines: wines, spirits: spirits);
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({required this.stats});
  final _Stats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: _StatTile(
                  label: context.l10n.journalStatTastings, value: stats.total)),
          Container(
            width: 1,
            height: 40,
            color: context.appColors.borderSubtle,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
              child: _StatTile(
                  label: context.l10n.journalStatWines, value: stats.wines)),
          Container(
            width: 1,
            height: 40,
            color: context.appColors.borderSubtle,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
              child: _StatTile(
                  label: context.l10n.journalStatSpirits,
                  value: stats.spirits)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: AppMotion.ticker,
          curve: AppMotion.standard,
          builder: (_, v, __) => Text(
            v.round().toString(),
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              height: 1,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.eyebrow.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

// ============================================================
// BroCard timeline row
// ============================================================

class _BroCardTimelineRow extends StatelessWidget {
  const _BroCardTimelineRow({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = entry.rating * 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: AppElevation.e1(dark: isDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bottle thumb (gradient fallback until photo lands)
          Container(
            width: 56,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.paprika, colors.paprikaDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.wine_bar, color: colors.inkOnHero, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.productName,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.category}${entry.region.isNotEmpty ? ' · ${entry.region}' : ''}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event, size: 12, color: colors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.shortDate(entry.createdAt),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: colors.textTertiary,
                      ),
                    ),
                    if (entry.buyAgain) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.favorite,
                          size: 12, color: context.paprikaOnSurface),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.actionBuyAgain,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.paprikaOnSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Score badge
          Column(
            children: [
              Text(
                score.toString(),
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: colors.gold,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '/10',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colors.textTertiary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Cinematic empty state — full-bleed photo + dual CTA
// ============================================================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            HeroPhotoCard(
              aspectRatio: 1,
              gradientColors: [
                colors.paprikaDeep,
                colors.paprika,
                colors.thunder,
              ],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.goldWarm,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      context.l10n.journalEmptyEyebrow,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colors.thunder,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.journalEmptyHeadline,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: colors.inkOnHero,
                      height: 1.05,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Every bottle becomes a BroCard.\nYour palate, in your pocket.',
                    style: context.serifQuote.copyWith(
                      color: colors.inkOnHero.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: Text(context.l10n.journalCtaScan),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context, rootNavigator: true)
                          .pushNamed('/scan');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(context.l10n.journalCtaLogManually),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      QuickLogSheet.show(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BroCardSheet extends ConsumerStatefulWidget {
  const BroCardSheet({this.productName, this.productCategory, this.productRegion, super.key});

  final String? productName;
  final String? productCategory;
  final String? productRegion;

  static void show(BuildContext context, {String? productName, String? category, String? region}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BroCardSheet(
        productName: productName,
        productCategory: category,
        productRegion: region,
      ),
    );
  }

  @override
  ConsumerState<BroCardSheet> createState() => _BroCardSheetState();
}

class _BroCardSheetState extends ConsumerState<BroCardSheet> {
  int _step = 0;
  final _nameController = TextEditingController();
  String _category = 'Wine';
  final _regionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.productName != null) _nameController.text = widget.productName!;
    if (widget.productCategory != null) _category = widget.productCategory!;
    if (widget.productRegion != null) _regionController.text = widget.productRegion!;
  }
  String _colour = 'Ruby';
  String _clarity = 'Clear';
  String _intensity = 'Medium';
  String _noseIntensity = 'Medium';
  final _selectedAromas = <String>{};
  String _sweetness = 'Dry';
  String _palateAcidity = 'Medium';
  String _palateTannin = 'Medium';
  String _palateBody = 'Medium';
  String _finishLength = 'Medium';
  int _rating = 3;
  bool _buyAgain = false;
  final _notesController = TextEditingController();
  String? _bottlePhotoUrl;
  String? _labelPhotoUrl;
  bool _photoUploading = false;
  JournalContext? _context;
  late final String _draftId =
      DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final id = _draftId;
    final entry = JournalEntry(
      id: id,
      userId: uid,
      productId: id,
      productName: _nameController.text.trim(),
      category: _category,
      region: _regionController.text.trim(),
      rating: _rating,
      createdAt: DateTime.now(),
      appearance: AppearanceData(
        colour: _colour,
        clarity: _clarity,
        intensity: _intensity,
      ),
      noseIntensity: NoseIntensity.fromDisplay(_noseIntensity),
      noseAromas: _selectedAromas.toList(),
      palateSweetness: Sweetness.fromDisplay(_sweetness),
      palateAcidity: AcidityLevel.fromDisplay(_palateAcidity),
      palateTannin: TanninLevel.fromDisplay(_palateTannin),
      palateBody: BodyLevel.fromDisplay(_palateBody),
      finishLength: FinishLength.fromDisplay(_finishLength),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      buyAgain: _buyAgain,
      bottlePhotoUrl: _bottlePhotoUrl,
      labelPhotoUrl: _labelPhotoUrl,
      occasion: _context?.code,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journal')
        .doc(id)
        .set(entry.toMap());

    // ignore: discarded_futures
    ref.read(gamificationServiceProvider).recordAction(
          GamificationAction.journalEntry,
          category: _category,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: colors.charcoal,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [

          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: colors.surface4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.broCardTitle,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  l10n.broCardStepOf(_step + 1),
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStep(colors, l10n),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: Text(l10n.backButton),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _step < 5
                        ? () => setState(() => _step++)
                        : _save,
                    child: Text(_step < 5 ? l10n.nextButton : l10n.saveBroCard),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(AppColors colors, AppLocalizations l10n) {
    return switch (_step) {
      0 => _buildInfoStep(colors, l10n),
      1 => _buildAppearanceStep(colors, l10n),
      2 => _buildNoseStep(colors, l10n),
      3 => _buildPalateStep(colors, l10n),
      4 => _buildFinishStep(colors, l10n),
      5 => _buildSummaryStep(colors, l10n),
      _ => const SizedBox(),
    };
  }

  Widget _buildInfoStep(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.whatAreYouTasting, colors),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(hintText: l10n.drinkNameHint),
        ),
        const SizedBox(height: 12),
        SegmentedChipSelector(
          options: ['Wine', 'Spirits', 'Beer', 'Cocktails'],
          selected: _category,
          onChanged: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regionController,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(hintText: l10n.regionOptionalHint),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _PhotoSlotTile(
                label: l10n.brocardPhotoBottle,
                photoUrl: _bottlePhotoUrl,
                colors: colors,
                busy: _photoUploading,
                onTap: () => _pickPhoto(PhotoSlot.bottle),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PhotoSlotTile(
                label: l10n.brocardPhotoLabel,
                photoUrl: _labelPhotoUrl,
                colors: colors,
                busy: _photoUploading,
                onTap: () => _pickPhoto(PhotoSlot.label),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          l10n.occasionPrompt,
          style: TextStyle(
            color: colors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        OccasionChips(
          selected: _context,
          onChanged: (c) => setState(() => _context = c),
        ),
      ],
    );
  }

  Future<void> _pickPhoto(PhotoSlot slot) async {
    if (_photoUploading) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) {
        final colors = ctx.appColors;
        return SafeArea(
          child: Container(
            color: colors.charcoal,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera, color: colors.paprika),
                  title: Text(ctx.l10n.brocardPhotoCamera,
                      style: TextStyle(color: colors.textPrimary)),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: colors.paprika),
                  title: Text(ctx.l10n.brocardPhotoGallery,
                      style: TextStyle(color: colors.textPrimary)),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source == null || !mounted) return;
    setState(() => _photoUploading = true);
    try {
      final url = await ref.read(broCardPhotoServiceProvider).captureAndUpload(
            entryId: _draftId,
            slot: slot,
            source: source,
          );
      if (!mounted) return;
      if (url != null) {
        setState(() {
          if (slot == PhotoSlot.bottle) {
            _bottlePhotoUrl = url;
          } else {
            _labelPhotoUrl = url;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.brocardPhotoUploadFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _photoUploading = false);
    }
  }

  Widget _buildAppearanceStep(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.appearanceTitle, colors),
        const SizedBox(height: 16),
        Text(l10n.colourLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedChipSelector(
            options: ['Straw', 'Gold', 'Ruby', 'Garnet', 'Purple'],
            selected: _colour,
            onChanged: (v) => setState(() => _colour = v)),
        const SizedBox(height: 16),
        Text(l10n.clarityLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedChipSelector(
            options: ['Clear', 'Slight Haze', 'Hazy'],
            selected: _clarity,
            onChanged: (v) => setState(() => _clarity = v)),
        const SizedBox(height: 16),
        Text(l10n.intensityLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedChipSelector(
            options: ['Pale', 'Medium', 'Deep'],
            selected: _intensity,
            onChanged: (v) => setState(() => _intensity = v)),
      ],
    );
  }

  Widget _buildNoseStep(AppColors colors, AppLocalizations l10n) {
    // Single source of truth: aroma_taxonomy.dart's kAromaWheel.
    // Per category, surface the first subcategory's aromas (~5-7 per group)
    // — keeps the BroCard form scannable while staying brand-coherent
    // with the Aroma Wheel exploration screen and capturing the
    // India-specific terms (Champa, Elaichi, Pudina, Tandoor smoke, etc.).
    final aromaCategories = {
      for (final cat in kAromaWheel) cat.name: cat.subcategories.first.aromas,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.noseTitle, colors),
        const SizedBox(height: 16),
        Text(l10n.intensityLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedChipSelector(
            options: ['Light', 'Medium', 'Pronounced'],
            selected: _noseIntensity,
            onChanged: (v) => setState(() => _noseIntensity = v)),
        const SizedBox(height: 20),
        Text(l10n.aromasSelectLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        for (final entry in aromaCategories.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(entry.key, style: TextStyle(color: colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entry.value.map((aroma) {
              final isSelected = _selectedAromas.contains(aroma);
              return GestureDetector(
                onTap: () => setState(() {
                  isSelected ? _selectedAromas.remove(aroma) : _selectedAromas.add(aroma);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.paprika.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? colors.paprika : colors.borderDefault),
                  ),
                  child: Text(aroma, style: TextStyle(color: isSelected ? colors.paprikaLight : colors.textSecondary, fontSize: 11)),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPalateStep(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.palateTitle, colors),
        const SizedBox(height: 16),
        Text(l10n.sweetnessLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedChipSelector(
            options: ['Dry', 'Off-Dry', 'Medium', 'Sweet', 'Luscious'],
            selected: _sweetness,
            onChanged: (v) => setState(() => _sweetness = v)),
        const SizedBox(height: 16),
        Text(l10n.acidityLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedChipSelector(
            options: ['Low', 'Medium', 'High'],
            selected: _palateAcidity,
            onChanged: (v) => setState(() => _palateAcidity = v)),
        const SizedBox(height: 16),
        Text(l10n.tanninLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedChipSelector(
            options: ['Low', 'Medium', 'High'],
            selected: _palateTannin,
            onChanged: (v) => setState(() => _palateTannin = v)),
        const SizedBox(height: 16),
        Text(l10n.bodyLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedChipSelector(
            options: ['Light', 'Medium', 'Full'],
            selected: _palateBody,
            onChanged: (v) => setState(() => _palateBody = v)),
      ],
    );
  }

  Widget _buildFinishStep(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.finishAndRating, colors),
        const SizedBox(height: 16),
        Text(l10n.finishLengthLabel, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedChipSelector(
            options: ['Short', 'Medium', 'Long'],
            selected: _finishLength,
            onChanged: (v) => setState(() => _finishLength = v)),
        const SizedBox(height: 24),
        Text(l10n.yourRating, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        StarRating(
          rating: _rating,
          size: 36,
          onChanged: (v) => setState(() => _rating = v),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          value: _buyAgain,
          onChanged: (v) => setState(() => _buyAgain = v),
          title: Text(l10n.wouldBuyAgain, style: TextStyle(color: colors.textPrimary, fontSize: 14)),
          activeColor: colors.salemLight,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          style: TextStyle(color: colors.textPrimary),
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.personalNotesHint),
        ),
      ],
    );
  }

  Widget _buildSummaryStep(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.yourBroCard, colors),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.thunder, colors.paprikaDark.withValues(alpha: 0.5)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_nameController.text, style: const TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('$_category · ${_regionController.text}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
              const SizedBox(height: 12),
              _summaryRow(l10n.appearanceTitle, '$_colour, $_clarity, $_intensity'),
              _summaryRow(l10n.noseTitle, '$_noseIntensity — ${_selectedAromas.take(3).join(', ')}'),
              _summaryRow(l10n.palateTitle, '$_sweetness, $_palateAcidity acid, $_palateTannin tannin, $_palateBody body'),
              _summaryRow(l10n.finishLengthLabel, _finishLength),
              const SizedBox(height: 8),
              Row(
                children: [
                  StarRating(rating: _rating, size: 18),
                  const Spacer(),
                  if (_buyAgain) Icon(Icons.thumb_up, color: colors.salemLight, size: 18),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text, AppColors colors) {
    return Text(text, style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary));
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12))),
        ],
      ),
    );
  }
}

class _PhotoSlotTile extends StatelessWidget {
  const _PhotoSlotTile({
    required this.label,
    required this.photoUrl,
    required this.colors,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final String? photoUrl;
  final AppColors colors;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: busy ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: photoUrl != null
                    ? colors.paprika.withValues(alpha: 0.5)
                    : colors.borderSubtle,
              ),
              image: photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl != null
                ? null
                : Center(
                    child: busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: colors.textTertiary, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  color: colors.textTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}

