import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../data/demo_data.dart';
import 'activity_detail.dart';

/// Ecran plein d'une activite (telephone). Sur tablette, la meme fiche
/// s'affiche dans le volet de droite du planning.
class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key, required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    final matches = activities.where((a) => a.id == activityId);
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.activity),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: matches.isEmpty
          ? const Center(child: Text(S.noActivitySelected))
          : ActivityDetail(
              activity: matches.first,
              onFinish: () => context.pop(),
            ),
    );
  }
}
