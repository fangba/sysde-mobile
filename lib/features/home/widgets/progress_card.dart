import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/strings.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/ring.dart';
import '../../../core/widgets/sys_widgets.dart';

/// Jauge "% effectuees" et compteurs Non traitees / Traitees. L'anneau se
/// remplit a l'ouverture ; le toucher rejoue l'animation (balayage, compteur
/// qui monte, petit rebond).
class ProgressCard extends StatefulWidget {
  const ProgressCard({super.key, required this.done, required this.planned});

  final int done;
  final int planned;

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void didUpdateWidget(ProgressCard old) {
    super.didUpdateWidget(old);
    if (old.done != widget.done || old.planned != widget.planned) _anim.forward(from: 0);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _replay() {
    HapticFeedback.selectionClick();
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final done = widget.done;
    final planned = widget.planned;
    final percent = planned == 0 ? 0 : (done / planned * 100).round();
    return SysCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _replay,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  final eased = Curves.easeOutCubic.transform(_anim.value);
                  final bounce = 1 + 0.06 * math.sin(math.pi * _anim.value);
                  return Transform.scale(
                    scale: bounce,
                    child: Ring(
                      value: (planned == 0 ? 0 : done / planned) * eased,
                      color: context.scheme.primary,
                      track: t.neutralBg,
                      size: 148,
                      strokeWidth: 12,
                      semanticLabel: '$percent % effectuées',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(percent * eased).round()}',
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3, left: 1),
                                child: Text(
                                  '%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                    color: context.scheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            S.percentDone,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: t.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              children: [
                _Counter(
                  value: planned - done,
                  label: S.notProcessed,
                  color: t.warnFg,
                  icon: Icons.trending_down,
                  iconColor: t.inkMuted,
                ),
                const SizedBox(height: 18),
                _Counter(
                  value: done,
                  label: S.processed,
                  color: context.scheme.primary,
                  icon: Icons.trending_up,
                  iconColor: context.scheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final int value;
  final String label;
  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: context.tokens.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: iconColor, semanticLabel: label),
        ],
      ),
    );
  }
}
