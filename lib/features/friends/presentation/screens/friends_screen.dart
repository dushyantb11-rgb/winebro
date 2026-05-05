import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/friends/data/friend_repository.dart';
import 'package:winebro/features/friends/domain/friend.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  bool _scanning = false;
  List<DiscoveredFriend>? _discovered;
  String? _error;

  Future<void> _discover() async {
    setState(() {
      _scanning = true;
      _error = null;
    });
    HapticFeedback.lightImpact();
    try {
      final list =
          await ref.read(friendRepositoryProvider).discoverFromContacts();
      if (!mounted) return;
      setState(() {
        _discovered = list;
        _scanning = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = context.l10n.friendsDiscoveryError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final friends = ref.watch(friendsStreamProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.friendsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _DiscoverCard(
            scanning: _scanning,
            error: _error,
            onTap: _discover,
            colors: colors,
          ),
          if (_discovered != null) ...[
            const SizedBox(height: 24),
            Text(
              context.l10n.friendsDiscoveredHeader(_discovered!.length),
              style: context.l10nEyebrow(colors),
            ),
            const SizedBox(height: 8),
            if (_discovered!.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  context.l10n.friendsNoneOnApp,
                  style: TextStyle(color: colors.textSecondary),
                ),
              )
            else
              ..._discovered!.map((d) => _DiscoveredRow(
                    discovered: d,
                    alreadyFollowed:
                        friends.any((f) => f.uid == d.uid),
                    colors: colors,
                  )),
          ],
          const SizedBox(height: 32),
          Text(
            context.l10n.friendsFollowingHeader(friends.length),
            style: context.l10nEyebrow(colors),
          ),
          const SizedBox(height: 8),
          if (friends.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                context.l10n.friendsEmpty,
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            )
          else
            ...friends.map((f) => _FollowedRow(friend: f, colors: colors)),
        ],
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.scanning,
    required this.error,
    required this.onTap,
    required this.colors,
  });

  final bool scanning;
  final String? error;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: scanning ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: colors.paprika.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            scanning
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.paprika,
                    ),
                  )
                : Icon(Icons.contacts, color: colors.paprika, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.friendsDiscoverTitle,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    error ?? context.l10n.friendsDiscoverHint,
                    style: TextStyle(
                      color: error != null
                          ? context.paprikaOnSurface
                          : colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DiscoveredRow extends ConsumerWidget {
  const _DiscoveredRow({
    required this.discovered,
    required this.alreadyFollowed,
    required this.colors,
  });

  final DiscoveredFriend discovered;
  final bool alreadyFollowed;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(friendRepositoryProvider);
    final initial = (discovered.displayName.isNotEmpty
            ? discovered.displayName
            : discovered.contactName)
        .characters
        .first
        .toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.paprika,
            child: Text(initial,
                style: TextStyle(
                  color: colors.inkOnHero,
                  fontWeight: FontWeight.w800,
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discovered.displayName.isNotEmpty
                      ? discovered.displayName
                      : discovered.contactName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (discovered.contactName != discovered.displayName)
                  Text(
                    context.l10n.friendsAsContact(discovered.contactName),
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          if (alreadyFollowed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                context.l10n.friendsFollowing,
                style: TextStyle(
                  color: context.salemOnSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () => repo.follow(
                targetUid: discovered.uid,
                displayName: discovered.displayName.isNotEmpty
                    ? discovered.displayName
                    : discovered.contactName,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.paprika,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                context.l10n.friendsFollow,
                style: TextStyle(
                  color: colors.inkOnHero,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FollowedRow extends ConsumerWidget {
  const _FollowedRow({required this.friend, required this.colors});

  final Friend friend;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(friendRepositoryProvider);
    final initial = friend.displayName.isNotEmpty
        ? friend.displayName.characters.first.toUpperCase()
        : '?';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.surface2,
            child: Text(
              initial,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.displayName,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.person_remove_outlined,
                color: colors.textTertiary),
            tooltip: context.l10n.friendsUnfollow,
            onPressed: () => repo.unfollow(friend.uid),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  TextStyle l10nEyebrow(AppColors colors) => TextStyle(
        color: colors.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      );
}
