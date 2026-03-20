import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/journal/presentation/screens/journal_screen.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/shared/widgets/product_card.dart';
import 'package:string_similarity/string_similarity.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final _searchController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _textRecognizer = TextRecognizer();

  bool _isScanning = false;
  Product? _matchedProduct;
  List<Product> _searchResults = [];
  String? _scanError;

  @override
  void dispose() {
    _searchController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _scanLabel() async {
    setState(() {
      _isScanning = true;
      _scanError = null;
    });

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (image == null) {

        setState(() => _isScanning = false);
        return;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final recognized = await _textRecognizer.processImage(inputImage);

      try {
        await File(image.path).delete();
      } on FileSystemException {

      }

      if (recognized.text.isEmpty) {
        setState(() {
          _isScanning = false;
          _scanError = 'noTextFound';
        });
        return;
      }

      final allText = recognized.blocks.map((b) => b.text).join(' ');
      final match = _matchProductFromText(allText);

      setState(() {
        _isScanning = false;
        if (match != null) {
          _matchedProduct = match;
          _searchResults = [];
          _searchController.clear();
        } else {

          final longestBlock = recognized.blocks
              .reduce((a, b) => a.text.length > b.text.length ? a : b);
          _searchController.text = longestBlock.text;
          _search(longestBlock.text);
        }
      });
    } on Exception catch (e) {
      setState(() {
        _isScanning = false;
        _scanError = e.toString();
      });
    }
  }

  Product? _matchProductFromText(String ocrText) {
    final normalized = ocrText.toLowerCase();

    Product? bestMatch;
    double bestScore = 0;

    for (final product in kSeedProducts) {

      final nameScore = StringSimilarity.compareTwoStrings(
        product.name.toLowerCase(),
        normalized,
      );

      final containsName =
          normalized.contains(product.name.toLowerCase()) ? 0.8 : 0.0;

      final subScore = StringSimilarity.compareTwoStrings(
        product.subcategory.toLowerCase(),
        normalized,
      );

      final regionScore = StringSimilarity.compareTwoStrings(
        product.region.toLowerCase(),
        normalized,
      );

      final score = [nameScore, containsName, subScore * 0.5, regionScore * 0.3]
          .reduce((a, b) => a > b ? a : b);

      if (score > bestScore) {
        bestScore = score;
        bestMatch = product;
      }
    }

    return bestScore >= 0.25 ? bestMatch : null;
  }

  void _search(String query) {
    if (query.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    final results = kSeedProducts.map((product) {
      final nameSimilarity = StringSimilarity.compareTwoStrings(
        query.toLowerCase(),
        product.name.toLowerCase(),
      );
      final subSimilarity = StringSimilarity.compareTwoStrings(
        query.toLowerCase(),
        product.subcategory.toLowerCase(),
      );
      final regionSimilarity = StringSimilarity.compareTwoStrings(
        query.toLowerCase(),
        product.region.toLowerCase(),
      );
      final score = [nameSimilarity, subSimilarity, regionSimilarity]
          .reduce((a, b) => a > b ? a : b);
      return (product: product, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    setState(() {
      _searchResults = results
          .where((r) => r.score > 0.15)
          .take(5)
          .map((r) => r.product)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            GestureDetector(
              onTap: _isScanning ? null : _scanLabel,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: colors.surface1,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.borderDefault),
                ),
                child: _isScanning
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 80,
                            color: colors.paprika.withValues(alpha: 0.3),
                          ),
                          CircularProgressIndicator(color: colors.paprika),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: colors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.tapToScan,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.pointCamera,
                            style: TextStyle(
                              color: colors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          if (_scanError == 'noTextFound') ...[
                            const SizedBox(height: 12),
                            Text(
                              l10n.noTextDetected,
                              style: TextStyle(
                                color: colors.error,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (_scanError != null && _scanError != 'noTextFound') ...[
                            const SizedBox(height: 12),
                            Text(
                              _scanError!,
                              style: TextStyle(color: colors.error, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              l10n.orSearchByName,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.searchPlaceholder,
                prefixIcon: Icon(Icons.search, color: colors.textTertiary),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 16),

            ..._searchResults.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductCard(
                    product: product,
                    onTap: () => setState(() {
                      _matchedProduct = product;
                      _searchResults = [];
                      _searchController.clear();
                    }),
                  ),
                )),

            if (_matchedProduct != null) ...[
              const SizedBox(height: 16),
              _ScanResultCard(product: _matchedProduct!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanResultCard extends StatelessWidget {
  const _ScanResultCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.salemLight, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: colors.salemLight, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.productFound,
                style: TextStyle(
                  color: colors.salemLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${product.subcategory} · ${product.region}',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          if (product.abv != null) ...[
            const SizedBox(height: 2),
            Text(
              '${product.abv}% ABV',
              style: TextStyle(color: colors.textTertiary, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            product.tastingNotes,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: product.aromas.take(6).map((aroma) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.borderDefault),
                ),
                child: Text(
                  aroma,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => BroCardSheet.show(
                    context,
                    productName: product.name,
                    category: product.category.group,
                    region: product.region,
                  ),
                  icon: const Icon(Icons.book, size: 16),
                  label: Text(l10n.addToJournal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/pair'),
                  icon: const Icon(Icons.restaurant_menu, size: 16),
                  label: Text(l10n.findPairingsButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

