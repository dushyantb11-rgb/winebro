import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';

/// Tells the truth about the catalogue: loading, could not load (with
/// retry) or empty. Shows nothing when the catalogue is ready.
class CatalogStateBanner extends ConsumerWidget {
  const CatalogStateBanner({super.key, this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 12)});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(catalogStatusProvider);
    final colors = context.appColors;
    final l10n = context.l10n;
    final (icon, text, color, retry) = switch (status) {
      CatalogStatus.ready => (null, null, null, false),
      CatalogStatus.loading => (Icons.cloud_download_outlined, l10n.catalogLoading, colors.info, false),
      CatalogStatus.empty => (Icons.inbox_outlined, l10n.catalogEmpty, colors.warning, false),
      CatalogStatus.error => (Icons.cloud_off_outlined, l10n.catalogError, colors.error, true),
    };
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color!.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textPrimary),
              ),
            ),
            if (retry)
              TextButton(
                onPressed: () => ref.read(catalogRefreshProvider)(),
                child: Text(l10n.tryAgain),
              ),
          ],
        ),
      ),
    );
  }
}
