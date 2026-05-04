import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_motion.dart';

/// 4-tab bottom nav (Home, Pair, Journal, Profile) + a center
/// floating action button that pushes the Scan modal.
///
/// Scan was previously a tab; demoted to a recurring action because:
///   1) It's a verb, not a destination
///   2) Iconic center FAB is more discoverable than a 5th tab
///   3) Premium consumer apps top out at 5 tabs (Vivino: 5, Distiller: 4)
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Scaffold(
      extendBody: true,
      body: shell,
      floatingActionButton: _ScanFab(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/scan');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        shell: shell,
        colors: colors,
        labels: [
          l10n.navHome,
          l10n.navPair,
          l10n.navJournal,
          l10n.navProfile,
        ],
      ),
    );
  }
}

class _ScanFab extends StatelessWidget {
  const _ScanFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.paprika.withValues(alpha: isDark ? 0.5 : 0.35),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: colors.paprika,
        elevation: 0,
        child: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.white),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.shell,
    required this.colors,
    required this.labels,
  });

  final StatefulNavigationShell shell;
  final AppColors colors;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.navBarBackground,
        border: Border(
          top: BorderSide(color: colors.borderSubtle, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: labels[0],
                isActive: shell.currentIndex == 0,
                onTap: () => _go(0),
                colors: colors,
              ),
              _NavItem(
                icon: Icons.restaurant_menu_outlined,
                activeIcon: Icons.restaurant_menu,
                label: labels[1],
                isActive: shell.currentIndex == 1,
                onTap: () => _go(1),
                colors: colors,
              ),
              // Spacer for the floating Scan button
              const SizedBox(width: 64),
              _NavItem(
                icon: Icons.book_outlined,
                activeIcon: Icons.book,
                label: labels[2],
                isActive: shell.currentIndex == 2,
                onTap: () => _go(2),
                colors: colors,
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: labels[3],
                isActive: shell.currentIndex == 3,
                onTap: () => _go(3),
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _go(int branch) {
    HapticFeedback.selectionClick();
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? colors.paprikaLight : colors.paprika;
    final color = isActive ? activeColor : colors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: AppMotion.fast,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
