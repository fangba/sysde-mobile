import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../data/demo_data.dart';
import '../../domain/control.dart';
import '../../domain/participant.dart';
import 'control_provider.dart';
import 'evaluation_panel.dart';
import 'photo_sheet_page.dart';

/// Rencontre d'un groupe de vulgarisation : liste de presence des membres
/// (present ou absent, sans evaluation).
class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key, required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final people = ref.watch(participantsProvider(activityId));
    final controls = ref.watch(controlsProvider);
    final notifier = ref.read(controlsProvider.notifier);
    final name = ref
        .watch(activitiesProvider)
        .where((a) => a.id == activityId)
        .map((a) => a.subjectName)
        .firstOrNull;

    Attendance? of(Participant p) => controls[controlKey(activityId, p.id)]?.attendance;
    final summary = summarizeControl(
      people.map((p) => ParticipantControl(attendance: of(p))),
    );
    final allDone = people.isNotEmpty && people.every((p) => of(p) != null);

    return PhotoSheetPage(
      title: S.actionAttendance,
      titleColor: context.scheme.primary,
      fallbackIcon: Icons.groups_outlined,
      backPath: '/action/$activityId',
      children: [
        if (name != null)
          Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        const SizedBox(height: 16),
        if (people.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(S.noParticipant, style: TextStyle(color: t.inkMuted)),
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          S.participants,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          for (final p in people) {
                            notifier.setAttendance(
                              controlKey(activityId, p.id),
                              Attendance.present,
                            );
                          }
                        },
                        child: const Text(S.markAllPresent),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Text(
                    S.controlSummary(summary.present, summary.absent, summary.pending),
                    style: TextStyle(fontSize: 12.5, color: t.inkMuted),
                  ),
                ),
                for (final p in people) ...[
                  Divider(height: 1, color: t.line),
                  _MemberRow(
                    person: p,
                    attendance: of(p),
                    onChanged: (a) => notifier.setAttendance(controlKey(activityId, p.id), a),
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
                      ..showSnackBar(const SnackBar(content: Text(S.attendanceSaved)));
                    context.pop();
                  }
                : null,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text(S.saveAttendance),
          ),
        ],
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.person, required this.attendance, required this.onChanged});

  final Participant person;
  final Attendance? attendance;
  final ValueChanged<Attendance> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: LayoutBuilder(
        builder: (context, c) {
          final info = Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: t.okBg,
                child: Icon(Icons.person_outline, size: 26, color: context.scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      person.phone,
                      style: TextStyle(fontSize: 13, color: t.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          );
          final choices = Row(
            children: [
              Expanded(
                child: ChoiceButton(
                  label: S.attPresent,
                  icon: Icons.check_circle_outline,
                  color: t.okFg,
                  selected: attendance == Attendance.present,
                  compact: true,
                  onTap: () => onChanged(Attendance.present),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceButton(
                  label: S.attAbsent,
                  icon: Icons.person_off_outlined,
                  color: t.dangerFg,
                  selected: attendance == Attendance.absent,
                  compact: true,
                  onTap: () => onChanged(Attendance.absent),
                ),
              ),
            ],
          );
          if (c.maxWidth >= 520) {
            return Row(
              children: [
                Expanded(child: info),
                const SizedBox(width: 16),
                SizedBox(width: 260, child: choices),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [info, const SizedBox(height: 10), choices],
          );
        },
      ),
    );
  }
}
