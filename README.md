# Fidenz Add To Calendar Plugin

## Android Integration

The following will need to be added to the `AndroidManifest.xml` file for your application to indicate permissions to modify calendars are needed

```xml
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```
## iOS Integration

For iOS 10+ support, you'll need to modify the `Info.plist` to add the following key/value pair

```xml
<key>NSCalendarsUsageDescription</key>
<string>Access most functions for calendar viewing and editing.</string>
```

For iOS 17+ support, add the following key/value pair as well.

```xml
<key>NSCalendarsFullAccessUsageDescription</key>
<string>Access most functions for calendar viewing and editing.</string>
```

Update the Podfile to include the necessary build settings for enabling calendar permissions by adding the following code inside the post_install block

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    // Add this after permission_handler installed on your project
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_EVENTS_FULL_ACCESS=1',
      ]
    end

  end
end
```


## Use it

```dart
import 'package:add_2_calendar/add_2_calendar.dart';

final Event event = Event(
    title: 'Calendar event',
    startTime: '2024-12-28T10:30:00',
    endTime: '2024-12-28T11:30:00',
    eventTimeZone: timezone
);
...
FlAddToCalender.addEvent(context, event);
...
```


