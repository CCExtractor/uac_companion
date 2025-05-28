import 'package:flutter/material.dart';
import 'time_picker.dart';
import '../utils/colors.dart';
import '../data/alarm_data.dart';

class Home extends StatefulWidget {
  final bool isRound;

  const Home({super.key, required this.isRound});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  void _loadAlarms() async {
    final alarms = await AlarmDatabase.instance.getAlarms();
    setState(() {
      _alarms = alarms;
    });
  }

  void _navigateToTimePicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimePickerScreen(isRound: widget.isRound),
      ),
    );

    if (result != null && mounted) {
      final int hour = result['hour'];
      final int minute = result['minute'];

      final int hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final String amPm = hour >= 12 ? 'PM' : 'AM';

      final String formattedTime =
          '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';

//! New Alarm formation
      final newAlarm = Alarm(
        time: formattedTime,
        days: 'Once',
      );

      await AlarmDatabase.instance.insertAlarm(newAlarm);
      _loadAlarms();
    }
  }

void _toggleAlarm(int index) async {
  final alarm = _alarms[index];

  final updatedAlarm = Alarm(
    id: alarm.id,
    time: alarm.time,
    days: alarm.days,
    enabled: !alarm.enabled,
  );

  setState(() {
    _alarms[index] = updatedAlarm;
  });

  await AlarmDatabase.instance.updateAlarm(updatedAlarm);
}


  @override
  Widget build(BuildContext context) {
    final isRound = widget.isRound;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isRound ? 25 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //! Add Alarm Button
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.grayBlack,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: AppColors.green, size: 28),
                  onPressed: _navigateToTimePicker,
                  padding: EdgeInsets.all(isRound ? 10 : 12),
                  constraints: BoxConstraints(
                    minWidth: isRound ? 40 : 50,
                    minHeight: isRound ? 40 : 50,
                  ),
                ),
              ),

              //! Alarm List
              if (_alarms.isEmpty)
                Center(
                  child: Text(
                    "Add a new Alarm",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isRound ? 12 : 16,
                    ),
                  ),
                )
              else
                ..._alarms.map((alarm) {
  return GestureDetector(
    onTap: () async {
      final parts = alarm.time.split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      final String amPm = parts[2];

      if (amPm == 'PM' && hour != 12) hour += 12;
      if (amPm == 'AM' && hour == 12) hour = 0;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TimePickerScreen(
            isRound: widget.isRound,
            initialHour: hour,
            initialMinute: minute,
            alarmId: alarm.id,
          ),
        ),
      );

      if (result != null && mounted) {
        final int newHour = result['hour'];
        final int newMinute = result['minute'];
        final int? alarmId = result['alarmId'];

        if (alarmId != null) {
          final hour12 = newHour % 12 == 0 ? 12 : newHour % 12;
          final amPm = newHour >= 12 ? 'PM' : 'AM';
          final formattedTime =
              '${hour12.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')} $amPm';

          final updatedAlarm = Alarm(
            id: alarmId,
            time: formattedTime,
            days: alarm.days,
            enabled: alarm.enabled,
          );

          await AlarmDatabase.instance.updateAlarm(updatedAlarm);
          _loadAlarms();
        }
      }
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.only(
        left: widget.isRound ? 11 : 14,
        top: widget.isRound ? 1 : 3,
        bottom: widget.isRound ? 1 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.grayBlack,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Alarm info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alarm.days,
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: widget.isRound ? 8 : 10,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${alarm.time.split(' ')[0]} ',
                      style: TextStyle(
                        fontSize: widget.isRound ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: alarm.time.split(' ')[1],
                      style: TextStyle(
                        fontSize: widget.isRound ? 10 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Right: Toggle
          Transform.scale(
            scale: widget.isRound ? 0.7 : 0.8,
            child: Switch(
              value: alarm.enabled,
              onChanged: (_) =>
                  _toggleAlarm(_alarms.indexOf(alarm)),
              activeColor: AppColors.green,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.black26,
            ),
          ),
        ],
      ),
    ),
  );
}).toList(),

            ],
          ),
        ),
      ),
    );
  }
}
