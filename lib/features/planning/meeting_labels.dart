import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../domain/meeting_type.dart';

extension MeetingTypeX on MeetingType {
  String get label => switch (this) {
        MeetingType.outreachGroup => S.meetingOutreach,
        MeetingType.conference => S.meetingConference,
        MeetingType.studyTrip => S.meetingStudyTrip,
        MeetingType.fair => S.meetingFair,
      };

  IconData get icon => switch (this) {
        MeetingType.outreachGroup => Icons.groups_outlined,
        MeetingType.conference => Icons.co_present_outlined,
        MeetingType.studyTrip => Icons.hiking,
        MeetingType.fair => Icons.workspace_premium_outlined,
      };
}
