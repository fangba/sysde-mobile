import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../domain/activity.dart';
import 'activity_carousel.dart';
import 'activity_section.dart';
import 'hub_cards.dart';

/// Menu Activite : une grande carte par section (programme, formations,
/// visites, rencontres). Une carte ouvre la liste correspondante.
class ActivityHubPage extends StatelessWidget {
  const ActivityHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = !context.isCompact;
    final t = context.tokens;

    void open(ActivitySection s) => context.go(s.path);

    final categoryCards = [
      for (final section in ActivitySection.values)
        if (section.category != null)
          CategoryHubCard(
            category: section.category!,
            title: section.title,
            subtitle: switch (section.category!) {
              ActivityCategory.training => S.hubTrainingSub,
              ActivityCategory.meeting => S.hubMeetingSub,
              ActivityCategory.visit => S.hubVisitSub,
            },
            onTap: () => open(section),
          ),
    ];

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
                const SizedBox(height: 4),
                Text(
                  S.activitiesSubtitle,
                  style: TextStyle(fontSize: 13, color: t.inkMuted),
                ),
                const SizedBox(height: 16),
                const ActivityCarousel(),
                const SizedBox(height: 20),
                ProgramHubCard(onTap: () => open(ActivitySection.program)),
                const SizedBox(height: 16),
                if (wide)
                  LayoutBuilder(
                    builder: (context, box) {
                      final w = (box.maxWidth - 32) / 3;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [for (final c in categoryCards) SizedBox(width: w, child: c)],
                      );
                    },
                  )
                else
                  for (final c in categoryCards) ...[c, const SizedBox(height: 12)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
