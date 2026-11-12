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
    this.showAttendance = true,
  });

  final ParticipantControl control;
  final ValueChanged<Attendance> onAttendance;
  final void Function(Criterion, Rating) onRate;
  final Map<Criterion, Rating>? reference;
  final Widget? footer;

  /// Faux quand la presence est deja faite (liste de presence) : seuls les
  /// criteres sont proposes.
  final bool showAttendance;

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
          if (showAttendance) ...[
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
          ],
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

/// Un critere : intitule a gauche, liste deroulante Bon / Moyen / Mauvais a droite.
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
      ],
    );
    final color = done ? _ratingColor(context, rating!) : t.inkMuted;
    final picker = Container(
      width: 160,
      height: 44,
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: done ? color.withValues(alpha: 0.08) : context.scheme.surface,
        border: Border.all(color: done ? color : t.line, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Rating>(
          value: rating,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          icon: Icon(Icons.keyboard_arrow_down, color: color),
          hint: Text(
            S.choose,
            style: TextStyle(fontSize: 14, color: t.inkMuted, fontWeight: FontWeight.w600),
          ),
          selectedItemBuilder: (context) => [
            for (final r in Rating.values)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  r.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _ratingColor(context, r),
                  ),
                ),
              ),
          ],
          items: [
            for (final r in Rating.values)
              DropdownMenuItem(
                value: r,
                child: Row(
                  children: [
                    Icon(r.icon, size: 18, color: _ratingColor(context, r)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _ratingColor(context, r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (r) {
            if (r != null) onRate(r);
          },
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Expanded(child: title),
          const SizedBox(width: 12),
          picker,
        ],
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
