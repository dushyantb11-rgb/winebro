import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';

/// Attribution for every open-licence photo shown in the app (CC BY and
/// CC BY-SA require naming the author, licence and source).
class PhotoCreditsScreen extends ConsumerWidget {
  const PhotoCreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final withPhotos = [
      for (final p in ref.watch(allProductsProvider))
        if (p.openFacts.photo != null) (p.name, p.openFacts.photo!),
      for (final d in ref.watch(allDishesProvider))
        if (d.photo != null) (d.name, d.photo!),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.photoCreditsTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        itemCount: withPhotos.length + 1,
        separatorBuilder: (_, __) => Divider(color: colors.borderSubtle, height: 1),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                context.l10n.photoCreditsIntro,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            );
          }
          final (name, photo) = withPhotos[i - 1];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(name, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
            subtitle: Text(photo.credit, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
            trailing: photo.pageUrl == null
                ? null
                : Icon(Icons.open_in_new, size: 18, color: colors.textTertiary),
            onTap: photo.pageUrl == null
                ? null
                : () => launchUrl(Uri.parse(photo.pageUrl!), mode: LaunchMode.externalApplication),
          );
        },
      ),
    );
  }
}
