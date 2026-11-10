import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../domain/control.dart';
import 'control_labels.dart';

/// Presence, puis cinq criteres notes Bon / Moyen / Mauvais. Avec `reference`
/// (notes du moniteur) l'ecart est indique ; `footer` vient apres les criteres.
class EvaluationPanel extends StatelessWidget {
  const EvaluationPanel({
    super.key,
    required this.control,
    required this.onAttendance,
    required this.onRate,
    this.reference,
    this.footer,
  });

  final ParticipantControl control;
  final ValueChanged<Attendance> onAttendance;
  final void Function(Criterion, Rating) onRate;
  final Map<Criterion, Rating>? reference;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final att = control.attendance;
    final total = Criterion.values.length;
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
                child: ChoiceButton(
                  label: S.attPresent,
                  icon: Icons.check_circle_outline,
                  color: t.okFg,
                  selected: att == Attendance.present,
                  onTap: () => onAttendance(Attendance.present),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceButton(
                  label: S.attAbsent,
                  icon: Icons.person_off_outlined,
                  color: t.dangerFg,
                  selected: att == Attendance.absent,
                  onTap: () => onAttendance(Attendance.absent),
                ),
              ),
            ],
          ),
          if (att == Attendance.absent) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: t.inkMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.absentNotEvaluated,
                    style: TextStyle(fontSize: 13, color: t.inkMuted),
                  ),
                ),
              ],
            ),
          ],
          if (att == Attendance.present) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  S.evaluationTitle,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(
                  '${control.ratedCount} / $total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: control.isComplete ? t.okFg : t.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: control.ratedCount / total,
                minHeight: 6,
                backgroundColor: t.line,
                color: control.isComplete ? t.okFg : context.scheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.scheme.surface,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  for (final (i, c) in Criterion.values.indexed) ...[
                    if (i > 0) Divider(height: 1, color: t.line),
                    _CriterionRow(
                      criterion: c,
                      rating: control.ratings[c],
                      reference: reference?[c],
                      onRate: (r) => onRate(c, r),
                    ),
                  ],
                ],
              ),
            ),
            if (footer != null) ...[const SizedBox(height: 16), footer!],
          ],
        ],
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

/// Un critere : intitule + trois choix Bon / Moyen / Mauvais.
/// Sur tablette, l'intitule est a gauche et les choix a droite sur une ligne.
class _CriterionRow extends StatelessWidget {
  const _CriterionRow({
    required this.criterion,
    required this.rating,
    required this.onRate,
    this.reference,
  });

  final Criterion criterion;
  final Rating? rating;
  final Rating? reference;
  final ValueChanged<Rating> onRate;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final done = rating != null;
    final title = Row(
      children: [
        Icon(criterion.icon, size: 20, color: done ? _ratingColor(context, rating!) : t.inkMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                criterion.label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              if (reference != null) _ReferenceLine(reference: reference!, rating: rating),
            ],
          ),
        ),
        if (done) Icon(Icons.check_circle, size: 18, color: _ratingColor(context, rating!)),
      ],
    );
    final choices = Row(
      children: [
        for (final r in Rating.values) ...[
          if (r != Rating.good) const SizedBox(width: 8),
          Expanded(
            child: ChoiceButton(
              label: r.label,
              icon: r.icon,
              color: _ratingColor(context, r),
              selected: rating == r,
              compact: true,
              onTap: () => onRate(r),
            ),
          ),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth >= 520) {
            return Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: 16),
                SizedBox(width: 330, child: choices),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, const SizedBox(height: 10), choices],
          );
        },
      ),
    );
  }
}

/// Bouton de choix (Present, Bon, Conforme...) : plein une fois selectionne.
class ChoiceButton extends StatelessWidget {
  const ChoiceButton({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    final fg = selected ? Colors.white : color;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? color : color.withValues(alpha: 0.07),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: color.withValues(alpha: selected ? 1 : 0.55), width: 1.5),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ExcludeSemantics(
            child: SizedBox(
              height: compact ? 42 : 46,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: compact ? 17 : 19, color: fg),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: compact ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ],
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

/// « Moniteur : Moyen » puis, une fois le critere note, l'ecart avec le moniteur.
class _ReferenceLine extends StatelessWidget {
  const _ReferenceLine({required this.reference, required this.rating});

  final Rating reference;
  final Rating? rating;

  static int _score(Rating r) => Rating.values.length - 1 - r.index;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final base = TextStyle(fontSize: 12, color: t.inkMuted);
    final r = rating;
    final gap = r == null ? null : _score(r) - _score(reference);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: '${S.monitorNote} : ${reference.label}'),
          if (gap != null)
            TextSpan(
              text: gap == 0
                  ? ' · ${S.gapSame}'
                  : ' · ${S.gapLabel} ${gap > 0 ? '+' : '−'}${gap.abs()}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: gap == 0 ? t.okFg : t.warnFg,
              ),
            ),
        ],
      ),
    );
  }
}
