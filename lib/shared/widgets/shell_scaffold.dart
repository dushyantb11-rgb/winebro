import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.navBarBackground,
          border: Border(
            top: BorderSide(color: colors.borderSubtle, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l10n.navHome,
                  isActive: shell.currentIndex == 0,
                  onTap: () => shell.goBranch(0),
                ),
                _NavItem(
                  icon: Icons.restaurant_menu_outlined,
                  activeIcon: Icons.restaurant_menu,
                  label: l10n.navPair,
                  isActive: shell.currentIndex == 1,
                  onTap: () => shell.goBranch(1),
                ),
                _NavItem(
                  icon: Icons.qr_code_scanner_outlined,
                  activeIcon: Icons.qr_code_scanner,
                  label: l10n.navScan,
                  isActive: shell.currentIndex == 2,
                  onTap: () => shell.goBranch(2),
                ),
                _NavItem(
                  icon: Icons.book_outlined,
                  activeIcon: Icons.book,
                  label: l10n.navJournal,
                  isActive: shell.currentIndex == 3,
                  onTap: () => shell.goBranch(3),
                ),
                _NavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: l10n.navCommunity,
                  isActive: shell.currentIndex == 4,
                  onTap: () => shell.goBranch(4),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: l10n.navProfile,
                  isActive: shell.currentIndex == 5,
                  onTap: () => shell.goBranch(5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isActive ? colors.paprikaLight : colors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

