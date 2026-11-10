import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/hero_header.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../data/sync_state.dart';
import '../../data/upload.dart';
import '../../domain/activity.dart';
import '../planning/activity_labels.dart';

/// Categories dans l'ordre d'affichage : Formations, Rencontres, Visites.
const _categories = [
  ActivityCategory.training,
  ActivityCategory.meeting,
  ActivityCategory.visit,
];

String _plural(ActivityCategory c) => switch (c) {
      ActivityCategory.training => S.catTrainingPlural,
      ActivityCategory.meeting => S.catMeetingPlural,
      ActivityCategory.visit => S.catVisitPlural,
    };

enum _Phase { select, sending, done }

enum _ItemState { queued, sending, sent, failed }

/// Envoi des donnees au serveur : l'utilisateur coche les activites terminees
/// (par onglet), puis suit l'envoi activite par activite et lit le bilan.
class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  _Phase _phase = _Phase.select;

  /// Activites cochees (toutes categories confondues).
  final _selected = <String>{};

  /// Lot en cours d'envoi (ou envoye) et etat de chaque activite.
  List<Activity> _batch = const [];
  final _states = <String, _ItemState>{};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _categories.length, vsync: this)
      ..addListener(() {
        if (!_tabs.indexIsChanging) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _toggle(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });

  void _toggleAll(List<Activity> items, bool select) => setState(() {
        for (final a in items) {
          select ? _selected.add(a.id) : _selected.remove(a.id);
        }
      });

  /// Lance l'envoi de la selection.
  Future<void> _sendSelection(List<Activity> pending) {
    final batch = [
      for (final c in _categories)
        for (final a in pending)
          if (a.category == c && _selected.contains(a.id)) a,
    ];
    _batch = batch;
    _states
      ..clear()
      ..addEntries(batch.map((a) => MapEntry(a.id, _ItemState.queued)));
    return _run(batch);
  }

  Future<void> _retryFailed() => _run([
        for (final a in _batch)
          if (_states[a.id] == _ItemState.failed) a,
      ]);

  Future<void> _run(List<Activity> todo) async {
    setState(() {
      _phase = _Phase.sending;
      for (final a in todo) {
        _states[a.id] = _ItemState.queued;
      }
    });
    final upload = ref.read(activityUploaderProvider);
    for (final a in todo) {
      if (!mounted) return;
      setState(() => _states[a.id] = _ItemState.sending);
      try {
        await upload(a);
        if (!mounted) return;
        setState(() => _states[a.id] = _ItemState.sent);
      } catch (_) {
        if (!mounted) return;
        setState(() => _states[a.id] = _ItemState.failed);
      }
    }
    final sent = [
      for (final a in _batch)
        if (_states[a.id] == _ItemState.sent) a.id,
    ];
    ref.read(sentActivitiesProvider.notifier).markSent(sent);
    if (sent.isNotEmpty) ref.read(lastSyncProvider.notifier).markSynced(ref.read(clockProvider)());
    _selected.removeAll(sent);
    setState(() => _phase = _Phase.done);
  }

  @override
  Widget build(BuildContext context) {
    final wide = !context.isCompact;
    final now = ref.watch(clockProvider)();
    final lastSync = ref.watch(lastSyncProvider);
    final pending = ref.watch(pendingUploadsProvider);
    List<Activity> of(ActivityCategory c) => [for (final a in pending) if (a.category == c) a];

    final failed = _states.values.where((s) => s == _ItemState.failed).length;
    final sentCount = _states.values.where((s) => s == _ItemState.sent).length;
    final handled = sentCount + failed;
    final picked = pending.where((a) => _selected.contains(a.id)).length;

    final (icon, title) = switch (_phase) {
      _Phase.select => (Icons.cloud_upload_outlined, S.sendTitle),
      _Phase.sending => (Icons.cloud_sync_outlined, S.sendRunning),
      _Phase.done => failed == 0
          ? (Icons.cloud_done_outlined, S.sendDone)
          : (Icons.cloud_off_outlined, S.sendPartial),
    };

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HeroHeader(
                    icon: icon,
                    title: title,
                    subtitle: '${S.offline} · ${formatLastSync(lastSync, now)}',
                    backPath: '/parametres',
                    loading: _phase == _Phase.sending,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16),
                          child: switch (_phase) {
                            _Phase.select => _buildSelect(pending, of, picked),
                            _Phase.sending => _Batch(
                                batch: _batch,
                                states: _states,
                                head: _ProgressCard(handled: handled, total: _batch.length),
                              ),
                            _Phase.done => _Batch(
                                batch: _batch,
                                states: _states,
                                head: _Bilan(sent: sentCount, failed: failed),
                              ),
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 8, wide ? 32 : 16, 12),
                  child: _bottomBar(pending, picked, failed),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(List<Activity> pending, int picked, int failed) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    switch (_phase) {
      case _Phase.select:
        return FilledButton.icon(
          onPressed: picked == 0 ? null : () => _sendSelection(pending),
          style: style,
          icon: const Icon(Icons.cloud_upload_outlined),
          label: Text(S.sendSelected(picked)),
        );
      case _Phase.sending:
        return FilledButton(onPressed: null, style: style, child: const Text(S.sendRunning));
      case _Phase.done:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (failed > 0) ...[
              OutlinedButton.icon(
                onPressed: _retryFailed,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text(S.sendRetry),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton.icon(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/parametres'),
              style: style,
              icon: const Icon(Icons.check),
              label: const Text(S.planDone),
            ),
          ],
        );
    }
  }

  Widget _buildSelect(
    List<Activity> pending,
    List<Activity> Function(ActivityCategory) of,
    int picked,
  ) {
    final t = context.tokens;
    if (pending.isEmpty) return const _AllSent();
    final items = of(_categories[_tabs.index]);
    final allPicked = items.isNotEmpty && items.every((a) => _selected.contains(a.id));
    final toCheck = pending.where((a) => a.anomaly != null).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: _cardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.selectedOf(picked, pending.length),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      if (toCheck > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$toCheck ${S.toCheck}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: t.warnFg,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    final all = pending.every((a) => _selected.contains(a.id));
                    _toggleAll(pending, !all);
                  }),
                  child: Text(
                    pending.every((a) => _selected.contains(a.id))
                        ? S.deselectAll
                        : S.selectAll,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabs,
          tabs: [
            for (final c in _categories)
              Tab(icon: Icon(c.icon), text: '${_plural(c)} · ${of(c).length}'),
          ],
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
            child: Text(
              S.nothingToSend,
              style: TextStyle(fontSize: 13.5, color: t.inkMuted),
            ),
          )
        else ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _toggleAll(items, !allPicked),
              icon: Icon(allPicked ? Icons.check_box_outline_blank : Icons.select_all),
              label: Text(allPicked ? S.deselectAll : S.selectAll),
            ),
          ),
          for (final a in items) ...[
            _ItemTile(
              activity: a,
              checked: _selected.contains(a.id),
              onToggle: () => _toggle(a.id),
            ),
            const SizedBox(height: 10),
          ],
        ],
        const SizedBox(height: 12),
      ],
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

class _AllSent extends StatelessWidget {
  const _AllSent();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: _cardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.cloud_done_outlined, size: 56, color: t.okFg),
            const SizedBox(height: 12),
            Text(
              S.sendAllDone,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.okFg),
            ),
            const SizedBox(height: 6),
            Text(
              S.sendAllDoneBody,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: t.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progression globale pendant l'envoi.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.handled, required this.total});

  final int handled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _cardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.sendProgress(handled, total),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: total == 0 ? 0 : handled / total),
                duration: const Duration(milliseconds: 400),
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  backgroundColor: context.tokens.line,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bilan de l'envoi : envoyees et echecs.
class _Bilan extends StatelessWidget {
  const _Bilan({required this.sent, required this.failed});

  final int sent;
  final int failed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ok = failed == 0;
    return DecoratedBox(
      decoration: _cardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ok ? Icons.check_circle : Icons.error_outline,
                    color: ok ? t.okFg : t.warnFg),
                const SizedBox(width: 8),
                Text(
                  ok ? S.sendDone : S.sendPartial,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ok ? t.okFg : t.warnFg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ok ? S.sendDoneBody(sent) : S.sendPartialBody(failed),
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Count(sent, S.syncSent, t.okBg, t.okFg),
                const SizedBox(width: 8),
                _Count(failed, S.sendFailed, t.dangerBg, t.dangerFg),
              ],
            ),
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

/// Lot en cours d'envoi : [head] puis les activites par categorie, chacune
/// avec son etat (en attente, en cours, envoyee, echec).
class _Batch extends StatelessWidget {
  const _Batch({required this.batch, required this.states, required this.head});

  final List<Activity> batch;
  final Map<String, _ItemState> states;
  final Widget head;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        head,
        for (final c in _categories)
          if (batch.any((a) => a.category == c)) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(c.icon, size: 20, color: c.color(t)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _plural(c),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${batch.where((a) => a.category == c && states[a.id] == _ItemState.sent).length}'
                  ' / ${batch.where((a) => a.category == c).length}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: t.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final a in batch.where((a) => a.category == c)) ...[
              _SendingTile(activity: a, state: states[a.id] ?? _ItemState.queued),
              const SizedBox(height: 8),
            ],
          ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SendingTile extends StatelessWidget {
  const _SendingTile({required this.activity, required this.state});

  final Activity activity;
  final _ItemState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final Widget trailing = switch (state) {
      _ItemState.queued => Icon(Icons.schedule, color: t.inkMuted),
      _ItemState.sending => const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      _ItemState.sent => Icon(Icons.check_circle, color: t.okFg),
      _ItemState.failed => Icon(Icons.error, color: t.dangerFg),
    };
    return SysCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: activity.category.color(t),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.place} · ${formatDay(activity.date)}',
                  style: TextStyle(fontSize: 12.5, color: t.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(key: ValueKey(state), child: trailing),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.activity, required this.checked, required this.onToggle});

  final Activity activity;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final check = activity.anomaly != null;
    final (label, bg, fg) = check
        ? (S.syncReview, t.warnBg, t.warnFg)
        : (S.syncPending, t.neutralBg, t.neutralFg);
    return Semantics(
      checked: checked,
      label: activity.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onToggle,
        child: ExcludeSemantics(
          child: SysCard(
            padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
            color: checked ? t.brandSoft : null,
            borderColor: checked ? context.scheme.primary : null,
            child: Row(
              children: [
                Checkbox(value: checked, onChanged: (_) => onToggle()),
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: activity.category.color(t),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${activity.place} · ${formatDay(activity.date)}',
                        style: TextStyle(fontSize: 12.5, color: t.inkMuted),
                      ),
                      if (check) ...[
                        const SizedBox(height: 2),
                        Text(
                          activity.anomaly!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: t.warnFg,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                StatusPill(label: label, background: bg, foreground: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
