import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../data/demo_data.dart';
import '../../domain/control.dart';
import '../../domain/participant.dart';
import 'control_provider.dart';
import 'photo_sheet_page.dart';
import 'visit_actions_page.dart';

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
    final activity =
        ref.watch(activitiesProvider).where((a) => a.id == activityId).firstOrNull;

    Attendance? of(Participant p) => controls[controlKey(activityId, p.id)]?.attendance;
    final presentCount = people.where((p) => of(p) == Attendance.present).length;

    return PhotoSheetPage(
      title: S.actionAttendance,
      titleColor: context.scheme.primary,
      fallbackIcon: Icons.groups_outlined,
      backPath: '/action/$activityId',
      children: [
        if (activity != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: brandGradient(context, radius: BorderRadius.circular(16)),
            child: Text(
              activityHeading(activity),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
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
                    S.presentOf(presentCount, people.length),
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
            onPressed: () {
              // Un interrupteur laisse a "absent" tant qu'il n'est pas allume :
              // a l'enregistrement, tout membre non pointe est absent.
              for (final p in people) {
                if (of(p) == null) {
                  notifier.setAttendance(controlKey(activityId, p.id), Attendance.absent);
                }
              }
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text(S.attendanceSaved)));
              context.pop();
            },
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
    final present = attendance == Attendance.present;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(present ? Attendance.absent : Attendance.present),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: present ? t.okBg : t.neutralBg,
                child: Icon(
                  Icons.person_outline,
                  size: 26,
                  color: present ? context.scheme.primary : t.inkMuted,
                ),
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
              const SizedBox(width: 8),
              Text(
                present ? S.attPresent : S.attAbsent,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: present ? t.okFg : t.dangerFg,
                ),
              ),
              Switch(
                value: present,
                onChanged: (v) => onChanged(v ? Attendance.present : Attendance.absent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
