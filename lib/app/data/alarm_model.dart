class Alarm {
  final int? id;
  final String time; // Format: "HH:mm"
  final List<int> days; // 0 = Mon, ..., 6 = Sun
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
        'days': days.join(','), // Save as comma-separated string
        'enabled': enabled ? 1 : 0,
      };

  @override
  String toString() =>
      'Alarm(id: $id, time: $time, days: $days, enabled: $enabled)';
}
