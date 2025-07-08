import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late Map<DateTime, List<Map<String, dynamic>>> _events;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = {
      //Eventos de prueba
      DateTime.utc(2025, 6, 25): [
        {
          "title": 'Reunión con fisioterapeuta',
          "time": TimeOfDay(hour: 10, minute: 30),
        },
        {
          "title": 'Entrenamiento',
          "time": TimeOfDay(hour: 18, minute: 0),
        }
      ],
      DateTime.utc(2025, 6, 26): [
        {
          "title": 'Consulta nutricional',
          "time": TimeOfDay(hour: 14, minute: 15),
        }
      ],
    };
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventsToday = _getEventsForDay(_selectedDay);
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
            child: eventsToday.isEmpty
                ? const Center(child: Text("No hay eventos para este día"))
                : ListView.builder(
              itemCount: eventsToday.length,
              itemBuilder: (context, index) {
                final event = eventsToday[index];
                final TimeOfDay time = event["time"];
                final String formattedTime =
                time.format(context); // Ej: 10:30 AM

                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text("${event["title"]}"),
                    subtitle: Text("Hora: $formattedTime"),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
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
      builder: (_) => StatefulBuilder(
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
                        _selectedDay.year, _selectedDay.month, _selectedDay.day);
                    setState(() {
                      if (_events[day] == null) {
                        _events[day] = [
                          {"title": text, "time": selectedTime}
                        ];
                      } else {
                        _events[day]!.add({"title": text, "time": selectedTime});
                      }
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


}
