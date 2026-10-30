import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../data/demo_data.dart';
import 'activity_carousel.dart';
import 'activity_section.dart';
import 'section_card.dart';

/// Menu Activite : une grande carte par section (programme, formations,
/// visites, rencontres). Une carte ouvre la liste correspondante.
class ActivityHubPage extends ConsumerWidget {
  const ActivityHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(categoryStatsProvider);

    String describe(ActivitySection section) {
      final c = section.category;
      if (c == null) return S.sectionProgramDesc;
      final st = stats[c];
      if (st == null) return '';
      return S.pendingAndDone(st.pending, st.done);
    }

    final cards = [
      for (final section in ActivitySection.values)
        SectionCard(
          icon: section.icon,
          title: section.title,
          description: describe(section),
          onTap: () => context.go(section.path),
        ),
    ];

    final wide = !context.isCompact;
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: EdgeInsets.all(wide ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.activities,
                  style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                ActivityCarousel(height: wide ? 290 : 215),
                const SizedBox(height: 16),
                if (wide)
                  LayoutBuilder(
                    builder: (context, box) => Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final c in cards) SizedBox(width: (box.maxWidth - 16) / 2, child: c),
                      ],
                    ),
                  )
                else
                  for (final c in cards) ...[c, const SizedBox(height: 12)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
