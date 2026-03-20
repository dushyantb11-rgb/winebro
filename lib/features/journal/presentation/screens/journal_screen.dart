import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_icons.dart';
import 'package:winebro/core/utils/formatters.dart';
import 'package:winebro/features/journal/domain/journal_entry.dart';
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

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final entries = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.journalTitle)),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(l10n.errorLoadingJournal, style: TextStyle(color: colors.error)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.journalEmpty,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.startLoggingTastings,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _JournalCard(entry: items[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.paprika,
        onPressed: () => _showBroCardSheet(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showBroCardSheet(BuildContext context, WidgetRef ref) {
    BroCardSheet.show(context);
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.paprikaDark.withValues(alpha: 0.3),
                  colors.surface2,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(AppIcons.journalEntry, size: 22, color: colors.paprikaLight),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.productName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.region} · ${Formatters.shortDate(entry.createdAt)}',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          StarRating(rating: entry.rating),
          const SizedBox(width: 8),
          if (entry.buyAgain)
            Icon(Icons.favorite, color: colors.paprika, size: 16),
        ],
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

    final id = DateTime.now().millisecondsSinceEpoch.toString();
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
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journal')
        .doc(id)
        .set(entry.toMap());

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
      ],
    );
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
    final aromaCategories = {
      'Fruity': ['Citrus', 'Berry', 'Stone Fruit', 'Tropical', 'Dried Fruit'],
      'Floral': ['Rose', 'Jasmine', 'Violet', 'Elderflower', 'Champa'],
      'Spice': ['Vanilla', 'Cinnamon', 'Pepper', 'Cardamom', 'Clove'],
      'Earthy': ['Mushroom', 'Wet Earth', 'Mineral', 'Leather', 'Tobacco'],
      'Oak': ['Toast', 'Cedar', 'Smoke', 'Coffee', 'Chocolate'],
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

