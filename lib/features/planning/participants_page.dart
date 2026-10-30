import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../data/demo_data.dart';
import '../../domain/control.dart';
import '../../domain/participant.dart';
import 'control_labels.dart';
import 'control_provider.dart';
import 'photo_sheet_page.dart';
import 'subject_labels.dart';

/// Controle : presence et evaluation des participants. Toucher un participant
/// deplie sa ligne vers le bas : presence, puis cinq criteres notes Bon /
/// Moyen / Mauvais (un absent n'est pas evalue).
class ParticipantsPage extends ConsumerStatefulWidget {
  const ParticipantsPage({super.key, required this.activityId});

  final String activityId;

  @override
  ConsumerState<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends ConsumerState<ParticipantsPage> {
  /// Participant deplie (un seul a la fois).
  String? _open;

  @override
  Widget build(BuildContext context) {
    final id = widget.activityId;
    final people = ref.watch(participantsProvider(id));
    final controls = ref.watch(controlsProvider);
    final t = context.tokens;
    final scheme = context.scheme;

    final name = ref
        .watch(activitiesProvider)
        .where((a) => a.id == id)
        .map((a) => a.subjectName)
        .firstOrNull;

    ParticipantControl of(Participant p) =>
        controls[controlKey(id, p.id)] ?? const ParticipantControl();
    final summary = summarizeControl(people.map(of));
    final allDone = people.isNotEmpty && people.every((p) => of(p).isComplete);

    return PhotoSheetPage(
      title: S.actionControl,
      titleColor: scheme.primary,
      fallbackIcon: Icons.school_outlined,
      backPath: '/action/$id',
      children: [
        if (name != null)
          Text(
            '${visitLabels.prefix} ${name.toUpperCase()}'.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  S.participants,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              if (people.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    S.controlSummary(summary.present, summary.absent, summary.pending),
                    style: TextStyle(fontSize: 12.5, color: t.inkMuted),
                  ),
                ),
              if (people.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(S.noParticipant, style: TextStyle(color: t.inkMuted)),
                  ),
                )
              else
                for (final p in people) ...[
                  Divider(height: 1, color: t.line),
                  _ParticipantTile(
                    person: p,
                    control: of(p),
                    open: _open == p.id,
                    onToggle: () => setState(() => _open = _open == p.id ? null : p.id),
                    onAttendance: (a) => ref
                        .read(controlsProvider.notifier)
                        .setAttendance(controlKey(id, p.id), a),
                    onRate: (c, r) => ref
                        .read(controlsProvider.notifier)
                        .setRating(controlKey(id, p.id), c, r),
                  ),
                ],
            ],
          ),
        ),
        if (people.isNotEmpty) ...[
          const SizedBox(height: 20),
          FilledButton(
            onPressed: allDone
                ? () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(content: Text(S.controlSaved)));
                    context.pop();
                  }
                : null,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text(S.saveControl),
          ),
        ],
      ],
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.person,
    required this.control,
    required this.open,
    required this.onToggle,
    required this.onAttendance,
    required this.onRate,
  });

  final Participant person;
  final ParticipantControl control;
  final bool open;
  final VoidCallback onToggle;
  final ValueChanged<Attendance> onAttendance;
  final void Function(Criterion, Rating) onRate;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: t.okBg,
                  child: Icon(Icons.school_outlined, size: 28, color: context.scheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${person.role.label} / ${person.phone}',
                        style: TextStyle(fontSize: 13, color: t.inkMuted),
                      ),
                      const SizedBox(height: 4),
                      _StatusText(control: control),
                    ],
                  ),
                ),
                Icon(open ? Icons.expand_less : Icons.expand_more, color: t.inkMuted),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: open
              ? _Evaluation(control: control, onAttendance: onAttendance, onRate: onRate)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.control});

  final ParticipantControl control;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (text, color, icon) = switch (control.attendance) {
      null => (S.attPending, t.inkMuted, Icons.help_outline),
      Attendance.absent => (S.attAbsent, t.dangerFg, Icons.person_off_outlined),
      Attendance.present => (
          control.isComplete
              ? '${S.attPresent} · ${S.evaluated}'
              : '${S.attPresent} · ${control.ratedCount}/${Criterion.values.length}',
          control.isComplete ? t.okFg : t.warnFg,
          control.isComplete ? Icons.check_circle_outline : Icons.timelapse,
        ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}

class _Evaluation extends StatelessWidget {
  const _Evaluation({
    required this.control,
    required this.onAttendance,
    required this.onRate,
  });

  final ParticipantControl control;
  final ValueChanged<Attendance> onAttendance;
  final void Function(Criterion, Rating) onRate;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final present = control.attendance == Attendance.present;
    return Container(
      width: double.infinity,
      color: t.okBg.withValues(alpha: 0.35),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(S.attendanceQuestion, style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Choice(
                  label: S.attPresent,
                  color: t.okFg,
                  selected: control.attendance == Attendance.present,
                  onTap: () => onAttendance(Attendance.present),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Choice(
                  label: S.attAbsent,
                  color: t.dangerFg,
                  selected: control.attendance == Attendance.absent,
                  onTap: () => onAttendance(Attendance.absent),
                ),
              ),
            ],
          ),
          if (present)
            for (final c in Criterion.values) ...[
              const SizedBox(height: 14),
              Text(c.label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final r in Rating.values) ...[
                    if (r != Rating.good) const SizedBox(width: 8),
                    Expanded(
                      child: _Choice(
                        label: r.label,
                        color: switch (r) {
                          Rating.good => t.okFg,
                          Rating.average => t.warnFg,
                          Rating.poor => t.dangerFg,
                        },
                        selected: control.ratings[c] == r,
                        onTap: () => onRate(c, r),
                      ),
                    ),
                  ],
                ],
              ),
            ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? color : context.scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: color, width: 1.5),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ExcludeSemantics(
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
