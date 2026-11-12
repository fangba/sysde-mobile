import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../data/demo_data.dart';
import '../../domain/control.dart';
import '../../domain/participant.dart';
import '../../domain/visit_type.dart';
import 'conformity_notes_page.dart';
import 'evaluation_panel.dart';
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
    // Visite de conformite : previsualisation des notes, sans saisie.
    final current = ref.watch(activitiesProvider).where((a) => a.id == id).firstOrNull;
    if (current?.visitType == VisitType.conformity) {
      return ConformityNotesPage(activity: current!);
    }
    final everyone = ref.watch(participantsProvider(id));
    final controls = ref.watch(controlsProvider);
    final presenceDone = ref.watch(visitProgressProvider(id)).attendance;
    final t = context.tokens;
    final scheme = context.scheme;

    final name = ref
        .watch(activitiesProvider)
        .where((a) => a.id == id)
        .map((a) => a.subjectName)
        .firstOrNull;

    ParticipantControl of(Participant p) =>
        controls[controlKey(id, p.id)] ?? const ParticipantControl();
    // La presence est faite avant : seuls les presents sont evalues.
    final people = [
      for (final p in everyone)
        if (of(p).attendance == Attendance.present) p,
    ];
    final evaluated = people.where((p) => of(p).isComplete).length;
    final allDone = people.isNotEmpty && evaluated == people.length;

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
                    S.evaluatedOf(evaluated, people.length),
                    style: TextStyle(fontSize: 12.5, color: t.inkMuted),
                  ),
                ),
              if (people.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      presenceDone ? S.noParticipant : S.presenceFirst,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.inkMuted),
                    ),
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
              ? EvaluationPanel(
                  control: control,
                  onAttendance: onAttendance,
                  onRate: onRate,
                  showAttendance: false,
                )
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
