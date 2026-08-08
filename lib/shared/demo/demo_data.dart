enum DemoEventType { training, meeting, match }

class DemoEvent {
  const DemoEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.start,
    required this.end,
    required this.location,
  });

  final String id;
  final String title;
  final DemoEventType type;
  final DateTime start;
  final DateTime end;
  final String location;
}

class DemoTeam {
  const DemoTeam({
    required this.id,
    required this.name,
    required this.playerCount,
    required this.season,
    this.ageGroup,
    this.nextOpponent,
    this.nextMatchAt,
  });

  final String id;
  final String name;
  final int playerCount;
  final String season;
  final String? ageGroup;
  final String? nextOpponent;
  final DateTime? nextMatchAt;
}

class DemoActivity {
  const DemoActivity({
    required this.playerName,
    required this.status,
    required this.whenLabel,
  });

  final String playerName;
  final String status;
  final String whenLabel;
}

class DemoMessageThread {
  const DemoMessageThread({
    required this.id,
    required this.title,
    required this.preview,
    required this.timeLabel,
    this.unread = 0,
    this.isGroup = false,
  });

  final String id;
  final String title;
  final String preview;
  final String timeLabel;
  final int unread;
  final bool isGroup;
}

class DemoPlayer {
  const DemoPlayer({
    required this.id,
    required this.name,
    required this.position,
    required this.number,
    required this.status,
    required this.dateOfBirth,
    required this.email,
    required this.phone,
    required this.parent,
    required this.jerseySize,
  });

  final String id;
  final String name;
  final String position;
  final int number;
  final String status;
  final String dateOfBirth;
  final String email;
  final String phone;
  final String parent;
  final String jerseySize;
}

/// Placeholder content so UI matches designs before full API wiring.
class DemoData {
  DemoData._();

  static final now = DateTime.now();

  static List<DemoTeam> get teams => [
        DemoTeam(
          id: 't1',
          name: 'U14 - Warriors',
          playerCount: 14,
          season: 'Season 2024/25',
          ageGroup: 'U14',
          nextOpponent: 'City FC',
          nextMatchAt: now.add(const Duration(days: 2, hours: 3)),
        ),
        const DemoTeam(
          id: 't2',
          name: 'U12 - Lions',
          playerCount: 12,
          season: 'Season 2024/25',
          ageGroup: 'U12',
        ),
        const DemoTeam(
          id: 't3',
          name: 'U16 - Eagles',
          playerCount: 16,
          season: 'Season 2024/25',
          ageGroup: 'U16',
        ),
      ];

  static List<DemoEvent> get events {
    final today = DateTime(now.year, now.month, now.day);
    return [
      DemoEvent(
        id: 'e1',
        title: 'Training',
        type: DemoEventType.training,
        start: today.add(const Duration(hours: 17)),
        end: today.add(const Duration(hours: 18, minutes: 30)),
        location: 'Main Field',
      ),
      DemoEvent(
        id: 'e2',
        title: 'Team Meeting',
        type: DemoEventType.meeting,
        start: today.add(const Duration(days: 1, hours: 16)),
        end: today.add(const Duration(days: 1, hours: 17)),
        location: 'Club House',
      ),
      DemoEvent(
        id: 'e3',
        title: 'Match',
        type: DemoEventType.match,
        start: today.add(const Duration(days: 2, hours: 10)),
        end: today.add(const Duration(days: 2, hours: 12)),
        location: 'City Stadium',
      ),
      DemoEvent(
        id: 'e4',
        title: 'Training',
        type: DemoEventType.training,
        start: today.add(const Duration(days: 3, hours: 17)),
        end: today.add(const Duration(days: 3, hours: 18, minutes: 30)),
        location: 'Main Field',
      ),
    ];
  }

  static const activities = [
    DemoActivity(
      playerName: 'John Smith',
      status: 'Injured',
      whenLabel: '2h ago',
    ),
    DemoActivity(
      playerName: 'Marco Rossi',
      status: 'Available',
      whenLabel: 'Yesterday',
    ),
  ];

  static const messages = [
    DemoMessageThread(
      id: 'm1',
      title: 'Team Group',
      preview: 'Training moved to 5:30 PM',
      timeLabel: '10:24',
      unread: 3,
      isGroup: true,
    ),
    DemoMessageThread(
      id: 'm2',
      title: 'John Smith',
      preview: 'I will be late tomorrow',
      timeLabel: 'Yesterday',
      unread: 1,
    ),
    DemoMessageThread(
      id: 'm3',
      title: 'Parents - Warriors',
      preview: 'Match day reminder attached',
      timeLabel: 'Mon',
      isGroup: true,
    ),
    DemoMessageThread(
      id: 'm4',
      title: 'Sarah Johnson',
      preview: 'Thanks coach!',
      timeLabel: 'Sun',
    ),
  ];

  static const player = DemoPlayer(
    id: 'p1',
    name: 'John Smith',
    position: 'Forward',
    number: 9,
    status: 'Active',
    dateOfBirth: '12 Mar 2011',
    email: 'john.parent@email.com',
    phone: '+389 70 123 456',
    parent: 'Mike Smith',
    jerseySize: 'M',
  );
}
