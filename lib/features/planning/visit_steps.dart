import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/sys_widgets.dart';
import '../../domain/visit_progress.dart';

/// Les trois etapes d'une visite : liste de presence, controle, rapport.
/// Une etape reste grisee (verrouillee) tant que la precedente n'est pas faite.
class VisitSteps extends StatelessWidget {
  const VisitSteps({
    super.key,
    required this.progress,
    required this.onAttendance,
    required this.onControl,
    required this.onReport,
    required this.onLocked,
  });

  final VisitProgress progress;
  final VoidCallback onAttendance;
  final VoidCallback onControl;
  final VoidCallback onReport;

  /// Appele quand on touche une etape verrouillee (avec le motif).
  final void Function(String reason) onLocked;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final steps = [
      _StepData(
        icon: Icons.fact_check_outlined,
        title: S.actionAttendance,
        description: S.stepAttendanceDesc,
        done: progress.attendance,
        locked: false,
        lockedReason: '',
        onTap: onAttendance,
      ),
      if (progress.hasControl)
        _StepData(
        icon: Icons.school_outlined,
        title: S.actionControl,
        description: S.stepControlDesc,
        done: progress.control,
        locked: !progress.controlUnlocked,
        lockedReason: S.stepLockedAttendance,
        onTap: onControl,
      ),
      _StepData(
        icon: Icons.assignment_outlined,
        title: S.actionReport,
        description: S.stepReportDesc,
        done: progress.report,
        locked: !progress.reportUnlocked,
        lockedReason: progress.hasControl ? S.stepLockedControl : S.stepLockedAttendance,
        onTap: onReport,
      ),
    ];
    // Etape en cours : la premiere ni terminee ni verrouillee.
    final current = steps.indexWhere((s) => !s.done && !s.locked);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: S.stepsProgress(progress.doneCount, progress.total),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.stepsProgress(progress.doneCount, progress.total),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress.doneCount / progress.total),
                    duration: const Duration(milliseconds: 350),
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      backgroundColor: t.line,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (final (i, s) in steps.indexed)
          _StepRow(
            number: i + 1,
            data: s,
            current: i == current,
            last: i == steps.length - 1,
            onLocked: onLocked,
          ),
      ],
    );
  }
}

class _StepData {
  const _StepData({
    required this.icon,
    required this.title,
    required this.description,
    required this.done,
    required this.locked,
    required this.lockedReason,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool done;
  final bool locked;
  final String lockedReason;
  final VoidCallback onTap;
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.data,
    required this.current,
    required this.last,
    required this.onLocked,
  });

  final int number;
  final _StepData data;
  final bool current;
  final bool last;
  final void Function(String reason) onLocked;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = context.scheme;
    final locked = data.locked;
    final done = data.done;

    final railColor = done
        ? t.okFg
        : locked
            ? t.line
            : scheme.primary;

    final Widget badge = Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done
            ? t.okFg
            : locked
                ? t.neutralBg
                : scheme.primary,
        shape: BoxShape.circle,
      ),
      child: done
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : locked
              ? Icon(Icons.lock_outline, size: 16, color: t.inkMuted)
              : Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
    );

    final (statusText, statusColor) = done
        ? (S.stepDone, t.okFg)
        : locked
            ? (data.lockedReason, t.inkMuted)
            : (S.stepTodo, scheme.primary);

    final onGradient = current;
    final titleColor = onGradient ? Colors.white : (locked ? t.inkMuted : null);
    final radius = BorderRadius.circular(18);

    final card = Semantics(
      button: true,
      enabled: !locked,
      label: '${data.title}, $statusText',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: onGradient
              ? brandGradient(context, radius: radius).copyWith(
                  boxShadow: [
                    BoxShadow(
                      color: t.deep.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                )
              : BoxDecoration(
                  color: locked ? t.neutralBg.withValues(alpha: 0.6) : scheme.surface,
                  borderRadius: radius,
                  border: Border.all(color: done ? t.okFg.withValues(alpha: 0.5) : t.line),
                ),
          child: InkWell(
            borderRadius: radius,
            onTap: locked ? () => onLocked(data.lockedReason) : data.onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: onGradient
                            ? Colors.white
                            : done
                                ? t.okBg
                                : t.neutralBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        data.icon,
                        size: 26,
                        color: locked ? t.inkMuted : scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locked || done ? statusText : data.description,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                              color: onGradient
                                  ? Colors.white
                                  : done
                                      ? statusColor
                                      : t.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      locked ? Icons.lock_outline : Icons.chevron_right,
                      color: onGradient ? Colors.white : t.inkMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                badge,
                if (!last)
                  Expanded(
                    child: Container(width: 2, color: railColor),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 14),
              child: card,
            ),
          ),
        ],
      ),
    );
  }
}
