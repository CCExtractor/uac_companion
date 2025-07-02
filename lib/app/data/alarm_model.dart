class Alarm {
  final int? id;
  final String time; //* Format: HH:mm (24-hour format)
  final List<int> days; //* Stores in android format (1 = Mon, ..., 7 = Sun)
  final bool enabled;

  Alarm({
    required this.id,
    required this.time,
    required this.days,
    required this.enabled,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'time': time,
        'days': days.join(','),
        'enabled': enabled ? 1 : 0,
      };

  @override
  String toString() =>
      'Alarm(id: $id, time: $time, days: $days, enabled: $enabled)';
}
