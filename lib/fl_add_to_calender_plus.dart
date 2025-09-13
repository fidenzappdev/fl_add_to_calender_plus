import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DeviceCalendar {
  final String id;
  final String display_name;
  final String account_name;
  final String calendar_color;

  DeviceCalendar({
    required this.id,
    required this.display_name,
    required this.account_name,
    required this.calendar_color
  });

  factory DeviceCalendar.fromMap(Map<String, dynamic> map) {
    return DeviceCalendar(
      id: map['id'] as String,
      display_name: map['display_name'] as String,
      account_name: map['account_name'] as String,
      calendar_color: map['calendar_color'] as String,
    );
  }
}

class Event {
  final String title;
  final String startTime;
  final String endTime;
  final String? description;
  final String eventTimeZone;
  final String? location;
  final String? eventId;
  final String? color;

  Event({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.eventTimeZone,
    this.description,
    this.location,
    this.eventId,
    this.color
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      eventTimeZone: map['eventTimeZone'] as String,
      description: map['description'] as String?,
      location: map['location'] as String?,
      eventId: map['eventId'] as String?,
      color: map['color'] as String?,
    );
  }
}

class FlAddToCalenderPlus {
  static const MethodChannel _channel = MethodChannel('fl_add_to_calender_plus');

  static Future _addEventToCalendar(
      {required Event event,
        Function? onPermissionDenied,
        required String calendarId}) async {
    try {
      String id = await _channel.invokeMethod('addEventToCalendar', {
        'title': event.title,
        'description': event.description,
        'startTime': _formattedDateTime(event.startTime),
        'endTime': _formattedDateTime(event.endTime),
        'timeZone': event.eventTimeZone,
        'location': event.location,
        'calendarId': calendarId
      });

      return id;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        if (onPermissionDenied != null) {
          onPermissionDenied();
        }
      } else {
        return e;
      }
    }
  }

  static Future _updateEvent(
      {required String eventId,
        required Event event,
        Function? onError,
        Function? onPermissionDenied}) async {
    try {
      String id = await _channel.invokeMethod('updateEvent', {
        'title': event.title,
        'description': event.description,
        'startTime': _formattedDateTime(event.startTime),
        'endTime': _formattedDateTime(event.endTime),
        'timeZone': event.eventTimeZone,
        'location': event.location,
        'eventId': eventId
      });

      return id;
    } on PlatformException catch (e) {
      debugPrint("ERROR $e");
      if (e.code == 'PERMISSION_DENIED') {
        if (onPermissionDenied != null) {
          onPermissionDenied();
        }
      } else {
        if(onError !=null){
          onError();
        }
      }
    }
  }

  static  Future<void> updateEvent(
      BuildContext context, {
        required String eventId,
        required Event event,
        Function? onPermissionDenied,
        Function? onError,
        Function? onSubmitted
      }) async {
    try {
      String response = await _updateEvent(eventId: eventId, event: event);
      if (onSubmitted != null) {
        onSubmitted(response);
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (onError != null) {
        onError();
      }
    }
  }

  static Future<void> addEvent(BuildContext context,
      {required Event event,
        Function? onPermissionDenied,
        Function? onError,
        Function? onSubmitted,
        String? dialogBoxTitle}) async {
    try {
      if (Platform.isAndroid) {
        List calendars = await _channel.invokeMethod('getCalendarList');
        List<DeviceCalendar> modelList = calendars
            .map((map) => DeviceCalendar.fromMap(_convertMap(map)))
            .toList();
        if (modelList.length == 1) {
          String createdEventId = await _addEventToCalendar(
              event: event, calendarId: modelList.first.id);
          if (onSubmitted != null) {
            onSubmitted(createdEventId);
          }
        } else {
          _showCalendarsListDialog(
              context: context,
              calendars: modelList,
              onCalendarSelected: (id) async {
                String createdEventId =
                await _addEventToCalendar(event: event, calendarId: id);
                if (onSubmitted != null) {
                  onSubmitted(createdEventId);
                }
              });
        }
      } else {
        String createdEventId =
        await _addEventToCalendar(event: event, calendarId: "0");
        if (onSubmitted != null) {
          onSubmitted(createdEventId);
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (onError != null) {
        onError();
      }
    }
  }
}

Map<String, dynamic> _convertMap(Map<Object?, Object?> originalMap) {
  Map<String, dynamic> convertedMap = {};

  originalMap.forEach((key, value) {
    if (key != null && value != null) {
      convertedMap[key.toString()] = value;
    } else {
      convertedMap[key?.toString() ?? 'null'] = value;
    }
  });

  return convertedMap;
}

void _showCalendarsListDialog({
  required Function(String) onCalendarSelected,
  required BuildContext context,
  required List<DeviceCalendar> calendars,
  String? dialogBoxTitle,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  dialogBoxTitle ?? 'Select a Calendar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  itemCount: calendars.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Row(
                        children: [
                          Container(
                            width: 15,
                            height: 15,
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _androidColorToFlutterColor(
                                  int.parse(calendars[index].calendar_color)),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              calendars[index].display_name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: calendars[index].display_name !=
                          calendars[index].account_name
                          ? Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text(calendars[index].account_name),
                      )
                          : const SizedBox.shrink(),
                      onTap: () {
                        Navigator.pop(context);
                        onCalendarSelected(calendars[index].id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Color _androidColorToFlutterColor(int androidColor) {
  int unsignedColor = androidColor & 0xFFFFFFFF;
  return Color(unsignedColor);
}

String _formattedDateTime(String time) {
  DateTime parsedDateTime = DateTime.parse(time);

  DateTime modelDateTime = DateTime.utc(
      parsedDateTime.year,
      parsedDateTime.month,
      parsedDateTime.day,
      parsedDateTime.hour,
      parsedDateTime.minute);
  DateTime localDateTime = modelDateTime.toLocal();
  String formattedDate =
  DateFormat('yyyy-MM-dd HH:mm:ss').format(localDateTime);
  return formattedDate;
}