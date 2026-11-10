import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../data/demo_data.dart';
import '../../domain/activity.dart';
import '../../domain/control.dart';
import '../../domain/participant.dart';
import 'control_labels.dart';
import 'control_provider.dart';
import 'evaluation_panel.dart';
import 'photo_sheet_page.dart';
import 'subject_labels.dart';

/// Controle d'une visite de conformite : on previsualise, pour chaque
/// participant de la plantation, les notes obtenues lors des visites de
/// plantation du moniteur. Consultation seulement : rien n'est saisi ici.
class ConformityNotesPage extends ConsumerWidget {
  const ConformityNotesPage({super.key, required this.activity});

  final Activity activity;

  static const _maxVisits = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final people = ref.watch(participantsProvider(activity.id));
    final all = ref.watch(conformityNotesProvider(activity.id));
    final visits = all.length > _maxVisits ? all.sublist(all.length - _maxVisits) : all;
    final controls = ref.watch(controlsProvider);
    final name = activity.subjectName;
    ParticipantControl of(Participant p) =>
        controls[controlKey(activity.id, p.id)] ?? const ParticipantControl();
    final allDone = people.isNotEmpty && people.every((p) => of(p).isConformityComplete);

    return PhotoSheetPage(
      title: S.actionControl,
      titleColor: context.scheme.primary,
      fallbackIcon: Icons.assignment_turned_in_outlined,
      backPath: '/action/${activity.id}',
      children: [
        if (name != null)
          Text(
            '${visitLabels.prefix} ${name.toUpperCase()}'.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        const SizedBox(height: 6),
        const Text(
          S.conformityNotesTitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          S.conformityNotesHint,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: t.inkMuted),
        ),
        const SizedBox(height: 16),
        if (people.isEmpty)
          const _Empty(text: S.noParticipant)
        else ...[
          if (visits.isEmpty)
            const _Empty(text: S.conformityNoVisit),
          for (final p in people) ...[
            _PersonNotes(
              activityId: activity.id,
              person: p,
              visits: visits,
              control: of(p),
              reference: _lastRatings(all, p.id),
            ),
            const SizedBox(height: 14),
          ],
          if (all.length > _maxVisits)
            Text(
              S.conformityLastThree,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: t.inkMuted),
            ),
          const SizedBox(height: 14),
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

/// Dernieres notes du moniteur pour ce participant (derniere visite ou il
/// etait present), pour afficher l'ecart pendant la saisie.
Map<Criterion, Rating>? _lastRatings(List<VisitNotes> all, String personId) {
  for (final v in all.reversed) {
    final c = v.byParticipant[personId];
    if (c != null && c.attendance == Attendance.present && c.ratings.isNotEmpty) {
      return c.ratings;
    }
  }
  return null;
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.tokens.inkMuted),
        ),
      ),
    );
  }
}

Color _ratingColor(BuildContext context, Rating r) {
  final t = context.tokens;
  return switch (r) {
    Rating.good => t.okFg,
    Rating.average => t.warnFg,
    Rating.poor => t.dangerFg,
  };
}

/// Carte d'un participant : identite, notes passees du moniteur, puis
/// evaluation de conformite (cinq criteres, note globale et commentaire).
class _PersonNotes extends ConsumerWidget {
  const _PersonNotes({
    required this.activityId,
    required this.person,
    required this.visits,
    required this.control,
    required this.reference,
  });

  final String activityId;
  final Participant person;
  final List<VisitNotes> visits;
  final ParticipantControl control;
  final Map<Criterion, Rating>? reference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final key = controlKey(activityId, person.id);
    final notifier = ref.read(controlsProvider.notifier);
    final controls = [for (final v in visits) v.byParticipant[person.id]];
    final hasNote = controls.any((c) => c != null);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: t.okBg,
                  child: Icon(Icons.school_outlined, size: 26, color: context.scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${person.role.label} / ${person.phone}',
                        style: TextStyle(fontSize: 13, color: t.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: t.line),
          if (!hasNote)
            const _Empty(text: S.conformityNoNote)
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: _NotesTable(visits: visits, controls: controls),
            ),
          Divider(height: 1, color: t.line),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
            child: EvaluationPanel(
              control: control,
              reference: reference,
              onAttendance: (a) => notifier.setAttendance(key, a),
              onRate: (c, r) => notifier.setRating(key, c, r),
              footer: _OverallBlock(
                control: control,
                onVerdict: (v) => notifier.setVerdict(key, v),
                onComment: (text) => notifier.setComment(key, text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Note globale du participant : conforme ou non conforme, avec commentaire
/// (obligatoire si non conforme).
class _OverallBlock extends StatefulWidget {
  const _OverallBlock({required this.control, required this.onVerdict, required this.onComment});

  final ParticipantControl control;
  final ValueChanged<Verdict> onVerdict;
  final ValueChanged<String> onComment;

  @override
  State<_OverallBlock> createState() => _OverallBlockState();
}

class _OverallBlockState extends State<_OverallBlock> {
  late final _text = TextEditingController(text: widget.control.comment);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final verdict = widget.control.verdict;
    final needComment = verdict == Verdict.nonCompliant && widget.control.comment.trim().isEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.scheme.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              S.overallTitle,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceButton(
                    label: S.verdictCompliant,
                    icon: Icons.verified_outlined,
                    color: t.okFg,
                    selected: verdict == Verdict.compliant,
                    onTap: () => widget.onVerdict(Verdict.compliant),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceButton(
                    label: S.verdictNonCompliant,
                    icon: Icons.cancel_outlined,
                    color: t.dangerFg,
                    selected: verdict == Verdict.nonCompliant,
                    onTap: () => widget.onVerdict(Verdict.nonCompliant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              onChanged: widget.onComment,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: S.commentLabel,
                hintText: S.commentHint,
                border: OutlineInputBorder(),
              ),
            ),
            if (needComment)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  S.commentRequired,
                  style: TextStyle(fontSize: 12, color: t.dangerFg),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotesTable extends StatelessWidget {
  const _NotesTable({required this.visits, required this.controls});

  final List<VisitNotes> visits;
  final List<ParticipantControl?> controls;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(flex: 4, child: SizedBox.shrink()),
            for (final (i, v) in visits.indexed)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        visitLabels.item(v.rank),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatDay(v.date),
                        style: TextStyle(fontSize: 11.5, color: t.inkMuted),
                      ),
                    ),
                    if (controls[i]?.attendance == Attendance.absent)
                      Text(
                        S.attAbsent,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: t.dangerFg,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final (r, c) in Criterion.values.indexed)
          Container(
            decoration: BoxDecoration(
              color: r.isEven ? t.okBg.withValues(alpha: 0.35) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Icon(c.icon, size: 16, color: t.inkMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c.label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final ctl in controls)
                  Expanded(
                    flex: 2,
                    child: Center(child: _RatingChip(rating: ctl?.ratings[c])),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});

  final Rating? rating;

  @override
  Widget build(BuildContext context) {
    final r = rating;
    if (r == null) {
      return Text(S.noNote, style: TextStyle(color: context.tokens.inkMuted));
    }
    final color = _ratingColor(context, r);
    return Semantics(
      label: r.label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                r.label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
