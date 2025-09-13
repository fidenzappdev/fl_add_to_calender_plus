import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'fl_add_to_calender_plus_platform_interface.dart';
import 'fl_add_to_calender_plus.dart';

/// An implementation of [FlAddToCalenderPlusPlatform] that uses method channels.
class MethodChannelFlAddToCalenderPlus extends FlAddToCalenderPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fl_add_to_calender_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<DeviceCalendar>> getAvailableCalendarApps() async {
    final List<dynamic>? result = await methodChannel.invokeMethod<List<dynamic>>('getAvailableCalendarApps');
    debugPrint("Result: $result");
    if (result == null) return [];
    return result.map((item) => DeviceCalendar.fromMap(Map<String, dynamic>.from(item))).toList();
  }

  @override
  Future<String?> addEventToCalendar({
    required Event event,
    Function? onPermissionDenied,
    required String calendarId
  }) async {
    String id = await methodChannel.invokeMethod('addEventToCalendar', {
      'title': event.title,
      'description': event.description,
      'startTime': _formattedDateTime(event.startTime),
      'endTime': _formattedDateTime(event.endTime),
      'timeZone': event.eventTimeZone,
      'location': event.location,
      'calendarId': calendarId
    });

    return id;
  }

  String _formattedDateTime(String time) {
    DateTime parsedDateTime = DateTime.parse(time);

    DateTime modelDateTime = DateTime.utc(
        parsedDateTime.year,
        parsedDateTime.month,
        parsedDateTime.day,
        parsedDateTime.hour,
        parsedDateTime.minute
    );
    DateTime localDateTime = modelDateTime.toLocal();
    String formattedDate =
    DateFormat('yyyy-MM-dd HH:mm:ss').format(localDateTime);
    return formattedDate;
  }
}
