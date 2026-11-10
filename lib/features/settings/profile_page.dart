import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/back_circle_button.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../data/demo_data.dart';
import '../../data/profile.dart';
import '../../data/sync_state.dart';
import '../../domain/activity.dart';
import '../../domain/user_profile.dart';

/// Profil de la personne connectee : bandeau vert avec avatar, chiffres du
/// mois, informations, affectation, puis desactivation du compte.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _deactivate(BuildContext context, WidgetRef ref, int unsent) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DeactivateDialog(unsent: unsent),
    );
    if (ok != true) return;
    deactivateLocalAccount(ref);
    router.go('/connexion');
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(S.accountDeactivated)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final wide = !context.isCompact;
    final p = ref.watch(profileProvider);
    final activities = ref.watch(activitiesProvider);
    final done = activities.where((a) => a.status == ActivityStatus.done).length;
    final todo = activities.length - done;
    final now = ref.watch(clockProvider)();
    final lastSync = formatLastSync(ref.watch(lastSyncProvider), now);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(profile: p),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Stats(total: activities.length, done: done, todo: todo),
                        const SizedBox(height: 22),
                        const _SectionTitle(S.profileInfo),
                        _Card(
                          rows: [
                            _Info(Icons.badge_outlined, S.profileMatricule, p.matricule),
                            _Info(Icons.work_outline, S.profileRole, p.role),
                            _Info(Icons.phone_outlined, S.profilePhone, p.phone),
                            _Info(Icons.mail_outline, S.profileEmail, p.email),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _SectionTitle(S.profileAssignment),
                        _Card(
                          rows: [
                            _Info(Icons.business_outlined, S.profileOperator, p.operatorName),
                            _Info(Icons.map_outlined, S.profileSector, p.sector),
                            _Info(Icons.grid_view_outlined, S.profileLot, p.lot),
                            _Info(Icons.place_outlined, S.profileSections, p.sections.join(' · ')),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _SectionTitle(S.profileDevice),
                        _Card(
                          rows: [
                            _Info(
                              Icons.verified_user_outlined,
                              S.profileStatus,
                              S.profileActive,
                              valueColor: t.okFg,
                            ),
                            _Info(Icons.sync, S.profileLastSync, lastSync),
                            const _Info(Icons.phone_android_outlined, S.profileApp, S.appVersion),
                          ],
                        ),
                        const SizedBox(height: 26),
                        _DangerZone(onDeactivate: () => _deactivate(context, ref, ref.read(pendingUploadsProvider).length)),
                        SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bandeau vert : retour, avatar a initiales, nom, poste et matricule.
class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: brandGradient(context),
      child: SizedBox(
        width: double.infinity,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 54),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BackCircleButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/parametres');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 104,
                  height: 104,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Text(
                    profile.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  profile.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${profile.role} · ${profile.matricule}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Trois chiffres du mois, dans une carte qui chevauche le bandeau.
class _Stats extends StatelessWidget {
  const _Stats({required this.total, required this.done, required this.todo});

  final int total;
  final int done;
  final int todo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget cell(String value, String label, Color color) => Expanded(
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 12.5, color: t.inkMuted)),
            ],
          ),
        );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.line),
        boxShadow: [
          BoxShadow(
            color: t.deep.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            cell('$total', S.statTotal, context.scheme.primary),
            SizedBox(height: 36, child: VerticalDivider(width: 1, color: t.line)),
            cell('$done', S.statDone, t.okFg),
            SizedBox(height: 36, child: VerticalDivider(width: 1, color: t.line)),
            cell('$todo', S.statTodo, t.warnFg),
          ],
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

class _Card extends StatelessWidget {
  const _Card({required this.rows});

  final List<_Info> rows;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.scheme.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final (i, r) in rows.indexed) ...[
            if (i > 0) Divider(height: 1, indent: 62, endIndent: 16, color: t.line),
            r,
          ],
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.label, this.value, {this.valueColor});

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.okBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: context.scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12.5, color: t.inkMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onDeactivate});

  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.dangerBg.withValues(alpha: 0.5),
        border: Border.all(color: t.dangerFg.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: t.dangerFg),
                const SizedBox(width: 8),
                Text(
                  S.dangerZone,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: t.dangerFg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(S.deactivateExplain, style: TextStyle(fontSize: 13.5, height: 1.4)),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onDeactivate,
              icon: const Icon(Icons.person_off_outlined),
              label: const Text(S.deactivateAccount),
              style: OutlinedButton.styleFrom(
                foregroundColor: t.dangerFg,
                backgroundColor: context.scheme.surface,
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: t.dangerFg),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeactivateDialog extends StatelessWidget {
  const _DeactivateDialog({required this.unsent});

  final int unsent;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget bullet(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6, right: 8),
                child: Icon(Icons.circle, size: 6),
              ),
              Expanded(child: Text(text)),
            ],
          ),
        );
    return AlertDialog(
      title: const Text(S.deactivateTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bullet(S.deactivateRights),
            bullet(S.deactivateData),
            bullet(S.deactivateNext),
            if (unsent > 0)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.warnBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 20, color: t.warnFg),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        S.deactivateUnsent(unsent),
                        style: TextStyle(color: t.warnFg, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(S.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: t.dangerFg),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(S.deactivateConfirm),
        ),
      ],
    );
  }
}
