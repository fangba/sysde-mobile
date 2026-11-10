import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../data/profile.dart';
import '../../data/sync_state.dart';

/// Parametres, par sections : Compte, Synchronisation, Aide.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final wide = !context.isCompact;
    final toSend = ref.watch(pendingUploadsProvider).length;
    final profile = ref.watch(profileProvider);
    final lastPlan = ref.watch(lastPlanningUpdateProvider);
    final lastSync = formatLastSync(ref.watch(lastSyncProvider), ref.watch(clockProvider)());
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: EdgeInsets.all(wide ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.settings,
                  style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                const _SectionTitle(S.settingsAccount),
                _Group(
                  rows: [
                    _Row(
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: t.okBg,
                        child: Icon(Icons.person_outline, color: context.scheme.primary),
                      ),
                      title: S.profile,
                      subtitle: '${profile.fullName} · ${profile.matricule}',
                      onTap: () => context.push('/parametres/profil'),
                    ),
                    _Row(
                      icon: Icons.logout,
                      color: t.dangerFg,
                      bg: t.dangerBg,
                      title: S.signOut,
                      titleColor: t.dangerFg,
                      chevron: false,
                      onTap: () => context.go('/connexion'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const _SectionTitle(S.sync),
                _Group(
                  rows: [
                    _Row(
                      icon: Icons.event_repeat_outlined,
                      color: context.scheme.primary,
                      bg: t.okBg,
                      title: S.planningUpdate,
                      subtitle: lastPlan == null ? S.planningUpdateDesc : S.planLastUpdateShort(formatDayTime(lastPlan)),
                      onTap: () => context.push('/parametres/planning'),
                    ),
                    _Row(
                      icon: Icons.cloud_upload_outlined,
                      color: t.warnFg,
                      bg: t.warnBg,
                      title: S.sendData,
                      subtitle: S.sendSummary(toSend, lastSync),
                      onTap: () => context.push('/parametres/synchro'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const _SectionTitle(S.settingsHelp),
                _Group(
                  rows: [
                    _Row(
                      icon: Icons.info_outline,
                      color: context.scheme.primary,
                      bg: t.okBg,
                      title: S.about,
                      subtitle: S.aboutDesc,
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => const _AboutDialog(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: context.tokens.inkMuted,
        ),
      ),
    );
  }
}

/// Carte arrondie qui regroupe les lignes d'une section, separees par des filets.
class _Group extends StatelessWidget {
  const _Group({required this.rows});

  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.scheme.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            for (final (i, r) in rows.indexed) ...[
              if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: t.line),
              r,
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.color,
    this.bg,
    this.leading,
    this.titleColor,
    this.chevron = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  final Color? bg;
  final Widget? leading;
  final Color? titleColor;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              leading ??
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color),
                  ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: TextStyle(fontSize: 13, color: t.inkMuted)),
                    ],
                  ],
                ),
              ),
              if (chevron) Icon(Icons.chevron_right, color: t.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// « A propos » : logo, nom, version et description, le tout centre.
class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 56,
                    height: 56,
                    excludeFromSemantics: true,
                    errorBuilder: (context, error, stack) =>
                        Icon(Icons.eco, size: 44, color: context.scheme.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      S.appName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.appVersion,
                      style: TextStyle(fontSize: 13.5, color: t.inkMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              S.aboutBody,
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14, height: 1.45),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(S.close),
        ),
      ],
    );
  }
}
