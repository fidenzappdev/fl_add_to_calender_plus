import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fl_add_to_calender_plus_method_channel.dart';
import 'fl_add_to_calender_plus.dart';

abstract class FlAddToCalenderPlusPlatform extends PlatformInterface {
  /// Constructs a FlAddToCalenderPlusPlatform.
  FlAddToCalenderPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlAddToCalenderPlusPlatform _instance = MethodChannelFlAddToCalenderPlus();

  /// The default instance of [FlAddToCalenderPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlAddToCalenderPlus].
  static FlAddToCalenderPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlAddToCalenderPlusPlatform] when
  /// they register themselves.
  static set instance(FlAddToCalenderPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<DeviceCalendar>> getAvailableCalendarApps() {
    throw UnimplementedError('getAvailableCalendarApps() has not been implemented.');
  }

  Future<String?> addEventToCalendar({
    required Event event,
    Function? onPermissionDenied,
    required String calendarId
  }) {
    throw UnimplementedError('addEventToCalendar() has not been implemented.');
  }
}
