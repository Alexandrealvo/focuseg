import 'package:flutter/material.dart';
import 'package:focus/src/pages/mapa_agenda.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Calendario extends StatefulWidget {
  Calendario({Key key}) : super(key: key);

  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> with TickerProviderStateMixin {
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  bool isLoading = true;

  // ApiCalendario calendario_api = new ApiCalendario();

  @override
  void initState() {
    super.initState();

    //final _selectedDay = DateTime.now();
    _calendarController = CalendarController();

    final _selectedDay = DateTime.now();
    // calendario_api.getAll();
    // _getCalendario()

    getData();

    _selectedEvents = [];
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  // _getCalendario() {
  //   calendario_api.getAll().then((value) {
  //     Iterable lista = json.decode(value.data);
  //     lista.map((model) => Dados_Agenda.fromJson(model)).toList();
  //   });
  // }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');

    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  Future getData() async {
    _events = {};

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idProf = prefs.getString('idusu');
    final response = await http
        .get("http://focuseg.com.br/flutter/agenda_json.php?idProf=$idProf");

    setState(() {
      var lista = json.decode(response.body);
      //agenda = lista.map((model) => Dados_Agenda.fromJson(model)).toList();
      //var jsonData = json.decode(response.body);

      for (var jsonElement in lista) {
        _events
            .putIfAbsent(
              DateTime.parse(jsonElement['data_agenda']),
              () => [],
            )
            .add(
                "${jsonElement['idos']} - ${jsonElement['cliente']} | ${jsonElement['hora_agenda']}h");
      }
      //print(lista[0]['idos']);
      isLoading = false;
    });
  }

  void _abrir_mapa(idOs) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('idOs', idOs);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MapaAgenda();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
        centerTitle: true,
        backgroundColor: Colors.red[900],
      ),
      body: isLoading
          ? Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Center(
                child: SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation(Colors.red[900]),
                  ),
                  height: 40,
                  width: 40,
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildTableCalendarWithBuilders(),
                  const SizedBox(height: 8.0),
                  const SizedBox(height: 8.0),
                  Expanded(child: _buildEventList()),
                ],
              ),
            ),
    );
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
        //locale: 'pl_PL',
        calendarController: _calendarController,
        events: _events,
        //holidays: _holidays,
        initialCalendarFormat: CalendarFormat.month,
        formatAnimation: FormatAnimation.slide,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableGestures: AvailableGestures.all,
        availableCalendarFormats: const {
          CalendarFormat.month: '',
          CalendarFormat.week: '',
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
          holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
        ),
        headerStyle: HeaderStyle(
          centerHeaderTitle: true,
          formatButtonVisible: false,
        ),
        builders: CalendarBuilders(
          selectedDayBuilder: (context, date, _) {
            return FadeTransition(
              opacity:
                  Tween(begin: 0.0, end: 1.0).animate(_animationController),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(10.0)),
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 16.0),
                ),
              ),
            );
          },
          todayDayBuilder: (context, date, _events) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            );
          },
          markersBuilder: (context, date, events, holidays) {
            final children = <Widget>[];

            if (events.isNotEmpty) {
              children.add(
                Positioned(
                  right: 1,
                  top: 1,
                  child: _buildEventsMarker(date, events),
                ),
              );
            }

            if (holidays.isNotEmpty) {
              children.add(
                Positioned(
                  right: -2,
                  top: -2,
                  child: _buildHolidaysMarker(),
                ),
              );
            }

            return children;
          },
        ),
        onDaySelected: _onDaySelected);
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _calendarController.isSelected(date)
            ? Colors.black
            : _calendarController.isToday(date)
                ? Colors.grey
                : Colors.grey,
      ),
      width: 18.0,
      height: 18.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.grey,
    );
  }

  // Widget _buildEventsMarker(DateTime date, List events) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     decoration: BoxDecoration(
  //       shape: BoxShape.rectangle,
  //       color: _calendarController.isSelected(date)
  //           ? Colors.brown[500]
  //           : _calendarController.isToday(date)
  //               ? Colors.brown[300]
  //               : Colors.blue[400],
  //     ),
  //     width: 16.0,
  //     height: 16.0,
  //     child: Center(
  //       child: Text(
  //         '${events.length}',
  //         style: TextStyle().copyWith(
  //           color: Colors.white,
  //           fontSize: 12.0,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildHolidaysMarker() {
  //   return Icon(
  //     Icons.add_box,
  //     size: 20.0,
  //     color: Colors.blueGrey[800],
  //   );
  // }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  //border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.red[900],
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(
                    event.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    var evento = event.split('-');
                    var idOs = evento[0];
                    //var descricao = evento[1];

                    _abrir_mapa(idOs);
                  },
                ),
              ))
          .toList(),
    );
  }
}
