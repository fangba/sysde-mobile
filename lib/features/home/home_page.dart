import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../data/demo_data.dart';
import '../../domain/attention.dart';
import 'widgets/attention_card.dart';
import 'widgets/category_panel.dart';
import 'widgets/home_header.dart';
import 'widgets/progress_card.dart';

/// Tableau de bord : avancement du mois, detail par categorie, activites a
/// traiter.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final activities = ref.watch(activitiesProvider);
    final summary = ref.watch(monthSummaryProvider);
    final stats = ref.watch(categoryStatsProvider);

    final attentionCard = AttentionCard(
      items: attentionItems(activities, today),
      onOpen: (id) => context.push('/fiche/$id'),
    );
    final progress = ProgressCard(done: summary.done, planned: summary.planned);
    final categories = CategoryPanel(stats: stats);

    final wide = !context.isCompact;
    const gap = SizedBox(height: 16);

    final pad = wide ? 32.0 : 16.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tete fixe : seul le contenu en dessous defile.
            Padding(
              padding: EdgeInsets.fromLTRB(pad, pad, pad, 12),
              child: const HomeHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, pad),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 13, child: Column(children: [progress, gap, categories])),
                          const SizedBox(width: 24),
                          Expanded(flex: 10, child: attentionCard),
                        ],
                      )
                    : Column(children: [progress, gap, categories, gap, attentionCard]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
