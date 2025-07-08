import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  late Map<DateTime, List<Map<String, dynamic>>> _events;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = _loadEventsFromHive();
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventsToday = _getEventsForDay(_selectedDay);

    //Ordenamos los eventos por hora
    eventsToday.sort((a, b) {
      final timeA = a['time'] as TimeOfDay;
      final timeB = b['time'] as TimeOfDay;
      return timeA.hour != timeB.hour
          ? timeA.hour.compareTo(timeB.hour)
          : timeA.minute.compareTo(timeB.minute);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Agenda"), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 10),
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) => _getEventsForDay(day),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFF0F8555),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF0F8555).withAlpha(100),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                eventsToday.isEmpty
                    ? const Center(child: Text("No hay eventos para este día"))
                    : ListView.builder(
                      itemCount: eventsToday.length,
                      itemBuilder: (context, index) {
                        final event = eventsToday[index];
                        final TimeOfDay time = TimeOfDay(
                          hour: event["hour"],
                          minute: event["minute"],
                        );
                        final String formattedTime = time.format(context);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.event),
                            title: Text("${event["title"]}"),
                            subtitle: Text("Hora: $formattedTime"),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addEventDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addEventDialog() {
    final controller = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: const Text("Agregar actividad"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Descripción del evento",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedTime == null
                                ? "Hora:  - - : - -"
                                : "Hora: ${selectedTime!.format(context)}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          child: const Text("Seleccionar hora"),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty && selectedTime != null) {
                        final day = DateTime.utc(
                          _selectedDay.year,
                          _selectedDay.month,
                          _selectedDay.day,
                        );
                        setState(() {
                          final event = {
                            "title": text,
                            "hour": selectedTime!.hour,
                            "minute": selectedTime!.minute,
                          };
                          _events[day] = [...?_events[day], event];
                          _saveEventsToHive();
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Agregar"),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _saveEventsToHive() {
    final box = Hive.box("eventsBox");
    final Map<String, List<Map<String, dynamic>>> data = {};
    for (var entry in _events.entries) {
      final key = _formatDateKey(entry.key);
      data[key] = entry.value;
    }

    //Guardamos bajo el UID del usuario
    box.put(_uid, data);
  }


  Map<DateTime, List<Map<String, dynamic>>> _loadEventsFromHive() {
    final box = Hive.box("eventsBox");
    final raw = box.get(_uid, defaultValue: <String, List<Map<String, dynamic>>>{});
    final Map<DateTime, List<Map<String, dynamic>>> result = {};
    for (var entry in (raw as Map).entries) {
      final parts = entry.key.split("-");
      final date = DateTime.utc(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      result[date] = List<Map<String, dynamic>>.from(entry.value);
    }
    return result;
  }

  String _formatDateKey(DateTime date) =>
      "${date.year}-${date.month}-${date.day}";
}
