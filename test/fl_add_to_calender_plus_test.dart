import 'package:flutter_test/flutter_test.dart';
import 'package:fl_add_to_calender_plus/fl_add_to_calender_plus.dart';
import 'package:fl_add_to_calender_plus/fl_add_to_calender_plus_platform_interface.dart';
import 'package:fl_add_to_calender_plus/fl_add_to_calender_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlAddToCalenderPlusPlatform
    with MockPlatformInterfaceMixin
    implements FlAddToCalenderPlusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> addEventToCalendar({required Event event, Function? onPermissionDenied, required String calendarId}) {
    // TODO: implement addEventToCalendar
    throw UnimplementedError();
  }

  @override
  Future<List<DeviceCalendar>> getAvailableCalendarApps() {
    // TODO: implement getAvailableCalendarApps
    throw UnimplementedError();
  }
}

void main() {
  final FlAddToCalenderPlusPlatform initialPlatform = FlAddToCalenderPlusPlatform.instance;

  test('$MethodChannelFlAddToCalenderPlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlAddToCalenderPlus>());
  });

  test('getPlatformVersion', () async {
    FlAddToCalenderPlus flAddToCalenderPlusPlugin = FlAddToCalenderPlus();
    MockFlAddToCalenderPlusPlatform fakePlatform = MockFlAddToCalenderPlusPlatform();
    FlAddToCalenderPlusPlatform.instance = fakePlatform;

    // expect(await flAddToCalenderPlusPlugin.getPlatformVersion(), '42');
  });
}
