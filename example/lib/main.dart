import 'dart:io';

import 'package:fl_add_to_calender_plus/fl_add_to_calender_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  String evID = "";

  Future<Event> buildEvent() async {
    var timezone = "Asia/kolkata";
    return Event(
        title: 'NB EVENT SEP 13',
        startTime: '2025-09-13T10:30:00',
        endTime: '2025-09-13T11:30:00',
        eventTimeZone: timezone);
  }

  Future<Event> getUpdateEvent() async {
    var timezone = "Asia/kolkata";
    return Event(
        title: 'NB EVENT Updated SEP 14',
        startTime: '2025-09-14T10:30:00',
        endTime: '2025-09-14T11:30:00',
        eventTimeZone: timezone);
  }

  void add() async {
    if (Platform.isAndroid) {
      var status = await Permission.calendarFullAccess.status;
      if (status == PermissionStatus.granted) {
        addEventToCalendar();
      } else if (status == PermissionStatus.permanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error adding event to calendar: Permission denied"),
          backgroundColor: Colors.red,
        ));
        Future.delayed(const Duration(seconds: 2), () {
          openAppSettings();
        });
      } else {
        if (await Permission.calendarFullAccess.request().isGranted) {
          addEventToCalendar();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error adding event to calendar: Permission denied"),
            backgroundColor: Colors.red,
          ));
        }
      }
    } else {
      var status = await Permission.calendarWriteOnly.status;
      debugPrint("Status $status");
      if (status == PermissionStatus.granted) {
        addEventToCalendar();
      } else if (status == PermissionStatus.permanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error adding event to calendar: Permission denied"),
          backgroundColor: Colors.red,
        ));
        Future.delayed(const Duration(seconds: 2), () {
          openAppSettings();
        });
      } else {
        debugPrint("Status $status");
        if (await Permission.calendarWriteOnly.request().isGranted) {
          addEventToCalendar();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error adding event to calendar: Permission denied"),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }



  void addEventToCalendar() async {
    await FlAddToCalenderPlus.addEvent(context, event: await buildEvent(),
        onSubmitted: (id) {
          evID = id;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Event added to calendar successfully ! ID = ${id}'),
            backgroundColor: Colors.green,
          ));
        }, onError: (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error $e'),
            backgroundColor: Colors.red,
          ));
        });
  }

  void updateEvent(String eventId) async {
    await FlAddToCalenderPlus.updateEvent(context, eventId: eventId,event: await getUpdateEvent(),
        onSubmitted: (status) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(status),
            backgroundColor: Colors.green,
          ));
        }, onError: (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error $e'),
            backgroundColor: Colors.red,
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fl Add To Calender'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                add();
              },
              child: Container(
                width: 200,
                height: 50,
                color: Colors.amber,
                child: const Center(child: Text("Add Event")),
              ),
            ),
            const SizedBox(height: 50,),
            InkWell(
              onTap: () async {
                updateEvent(evID);
              },
              child: Container(
                width: 200,
                height: 50,
                color: Colors.red,
                child: const Center(child: Text("Update Event")),
              ),
            )
          ],
        ),
      ),
    );
  }
}
