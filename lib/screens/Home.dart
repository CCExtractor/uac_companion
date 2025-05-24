//! Landing screen
import 'package:flutter/material.dart';
import 'TimePicker.dart';
import '../utils/Colors.dart';

class Alarm {
  String time;
  String days;
  bool enabled;

  Alarm({required this.time, required this.days, this.enabled = true});
}

class Home extends StatefulWidget {
  final bool isRound;

  const Home({super.key, required this.isRound});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final List<Alarm> _alarms = [];
  final List<Alarm> _alarms = [
    Alarm(time: '06:30 PM', days: 'Wed, Thur', enabled: true),
    Alarm(time: '10:27 AM', days: 'Weekdays', enabled: false),
    Alarm(time: '12:30 AM', days: 'Weekdays', enabled: false),
    Alarm(time: '08:00 AM', days: 'Weekdays', enabled: false),
    Alarm(time: '12:30 AM', days: 'Mon', enabled: true),
    Alarm(time: '12:30 AM', days: 'Weekdays', enabled: false),
  ];

//! navigates to timePicker screen
void _navigateToTimePicker() async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TimePickerScreen(isRound: widget.isRound),
    ),
  );
}


  void _toggleAlarm(int index) {
    setState(() {
      _alarms[index].enabled = !_alarms[index].enabled;
    });
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
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: EdgeInsets.only(
                    left: isRound ? 11 : 14,
                    top: isRound ? 1 : 3,
                    bottom: isRound ? 1 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grayBlack,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alarm.days,
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: isRound ? 8 : 10,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${alarm.time.split(' ')[0]} ',
                                  style: TextStyle(
                                    fontSize: isRound ? 16 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: alarm.time.split(' ')[1],
                                  style: TextStyle(
                                    fontSize: isRound ? 10 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Transform.scale(
                        scale: isRound ? 0.7 : 0.8,
                        child: Switch(
                          value: alarm.enabled,
                          onChanged: (_) => _toggleAlarm(_alarms.indexOf(alarm)),
                          activeColor: AppColors.green,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.black26,
                        ),
                      ),
                    ],
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
