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
import '../../data/planning_update.dart';
import '../../data/sync_state.dart';
import '../../domain/planning_update.dart';

enum _Phase { idle, running, done, failed }

/// Mise a jour du planning : etat du planning en vigueur, deroulement de la
/// mise a jour etape par etape, puis changements recus.
class PlanningUpdatePage extends ConsumerStatefulWidget {
  const PlanningUpdatePage({super.key});

  @override
  ConsumerState<PlanningUpdatePage> createState() => _PlanningUpdatePageState();
}

class _PlanningUpdatePageState extends ConsumerState<PlanningUpdatePage> {
  _Phase _phase = _Phase.idle;
  int _step = 0;
  List<PlanningChange> _changes = const [];

  Future<void> _run() async {
    setState(() {
      _phase = _Phase.running;
      _step = 0;
    });
    try {
      final changes = await ref.read(planningUpdaterProvider)((step) {
        if (mounted) setState(() => _step = step);
      });
      if (!mounted) return;
      ref.read(lastPlanningUpdateProvider.notifier).markUpdated(ref.read(clockProvider)());
      setState(() {
        _changes = changes;
        _phase = _Phase.done;
      });
    } catch (_) {
      if (mounted) setState(() => _phase = _Phase.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final wide = !context.isCompact;
    final last = ref.watch(lastPlanningUpdateProvider);
    final subtitle = last == null ? '—' : S.planLastUpdateShort(formatDayTime(last));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(subtitle: subtitle, phase: _phase),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_phase == _Phase.idle) ...[
                            _CurrentPlanning(last: last),
                            const SizedBox(height: 16),
                            const _Tip(),
                            const SizedBox(height: 22),
                            _MainButton(
                              icon: Icons.sync,
                              label: S.planSearch,
                              onPressed: _run,
                            ),
                          ],
                          if (_phase == _Phase.running) ...[
                            _Progress(step: _step),
                            const SizedBox(height: 22),
                            const _MainButton(label: S.planRunning),
                          ],
                          if (_phase == _Phase.done) ...[
                            _Result(changes: _changes),
                            const SizedBox(height: 22),
                            _MainButton(
                              icon: Icons.check,
                              label: S.planDone,
                              onPressed: () => context.canPop()
                                  ? context.pop()
                                  : context.go('/parametres'),
                            ),
                          ],
                          if (_phase == _Phase.failed) ...[
                            const _Failure(),
                            const SizedBox(height: 22),
                            _MainButton(
                              icon: Icons.refresh,
                              label: S.planRetry,
                              onPressed: _run,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            S.planDemo,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: t.inkMuted),
                          ),
                          SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
                        ],
                      ),
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

/// Bandeau vert : retour, grosse icone (qui tourne pendant la mise a jour).
class _Header extends StatelessWidget {
  const _Header({required this.subtitle, required this.phase});

  final String subtitle;
  final _Phase phase;

  @override
  Widget build(BuildContext context) {
    final (icon, ring) = switch (phase) {
      _Phase.done => (Icons.check_rounded, true),
      _Phase.failed => (Icons.cloud_off_outlined, false),
      _ => (Icons.event_repeat_outlined, false),
    };
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
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/parametres'),
                  ),
                ),
                const SizedBox(height: 2),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (phase == _Phase.running)
                      const SizedBox(
                        width: 112,
                        height: 112,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                          backgroundColor: Color(0x33FFFFFF),
                        ),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(icon),
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: ring ? 0.28 : 0.18),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(icon, size: 46, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  S.planningUpdate,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  final t = context.tokens;
  return BoxDecoration(
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
  );
}

class _CurrentPlanning extends ConsumerWidget {
  const _CurrentPlanning({required this.last});

  final DateTime? last;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final count = ref.watch(activitiesProvider).length;
    Widget row(IconData icon, String label, Widget value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
              Expanded(child: Text(label, style: TextStyle(fontSize: 13.5, color: t.inkMuted))),
              value,
            ],
          ),
        );
    return DecoratedBox(
      decoration: _cardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(S.planCurrent, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            row(
              Icons.calendar_month_outlined,
              S.planYear,
              const Text('2026', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
            Divider(height: 1, color: t.line),
            row(
              Icons.verified_outlined,
              S.profileStatus,
              StatusPill(label: S.planValidated, background: t.okBg, foreground: t.okFg),
            ),
            Divider(height: 1, color: t.line),
            row(
              Icons.history,
              S.planLastUpdate,
              Text(
                last == null ? '—' : formatDayTime(last!),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            Divider(height: 1, color: t.line),
            row(
              Icons.event_note_outlined,
              S.planActivities,
              Text(
                '$count',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.brandSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 20, color: context.scheme.primary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(S.planTip, style: TextStyle(fontSize: 13.5, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  const _MainButton({required this.label, this.icon, this.onPressed});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    return icon == null
        ? FilledButton(onPressed: onPressed, style: style, child: Text(label))
        : FilledButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon),
            label: Text(label),
          );
  }
}

/// Deroulement : barre de progression et quatre etapes (fait, en cours, a venir).
class _Progress extends StatelessWidget {
  const _Progress({required this.step});

  final int step;

  static const _labels = [
    S.planStepConnect,
    S.planStepCheck,
    S.planStepDownload,
    S.planStepSave,
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: _cardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: (step + 1) / _labels.length),
                duration: const Duration(milliseconds: 500),
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  backgroundColor: t.line,
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final (i, label) in _labels.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: i < step
                          ? Icon(Icons.check_circle, color: t.okFg)
                          : i == step
                              ? const Padding(
                                  padding: EdgeInsets.all(3),
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                )
                              : Icon(Icons.radio_button_unchecked, color: t.line),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: i == step ? FontWeight.w800 : FontWeight.w600,
                          color: i > step ? t.inkMuted : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.changes});

  final List<PlanningChange> changes;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    int count(PlanningChangeKind k) => changes.where((c) => c.kind == k).length;
    return DecoratedBox(
      decoration: _cardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: t.okFg),
                const SizedBox(width: 8),
                Text(
                  S.planUpToDate,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.okFg),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (changes.isEmpty)
              Text(S.planNoChange, style: TextStyle(color: t.inkMuted))
            else ...[
              Row(
                children: [
                  _Count(count(PlanningChangeKind.added), S.planAdded, t.okBg, t.okFg),
                  const SizedBox(width: 8),
                  _Count(count(PlanningChangeKind.changed), S.planChanged, t.warnBg, t.warnFg),
                  const SizedBox(width: 8),
                  _Count(count(PlanningChangeKind.removed), S.planRemoved, t.dangerBg, t.dangerFg),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                S.planChangesTitle,
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              for (final (i, c) in changes.indexed) ...[
                if (i > 0) Divider(height: 1, color: t.line),
                _ChangeTile(change: c),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.value, this.label, this.bg, this.fg);

  final int value;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fg)),
            Text(label, style: TextStyle(fontSize: 12, color: fg)),
          ],
        ),
      ),
    );
  }
}

class _ChangeTile extends StatelessWidget {
  const _ChangeTile({required this.change});

  final PlanningChange change;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (label, bg, fg) = switch (change.kind) {
      PlanningChangeKind.added => (S.planKindNew, t.okBg, t.okFg),
      PlanningChangeKind.changed => (S.planKindChanged, t.warnBg, t.warnFg),
      PlanningChangeKind.removed => (S.planKindRemoved, t.dangerBg, t.dangerFg),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  change.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(change.detail, style: TextStyle(fontSize: 12.5, color: t.inkMuted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusPill(label: label, background: bg, foreground: fg),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: _cardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: t.dangerFg),
                const SizedBox(width: 8),
                Text(
                  S.planFailed,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.dangerFg),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(S.planFailedBody, style: TextStyle(fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
