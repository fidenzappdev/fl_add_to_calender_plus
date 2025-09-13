//package com.fidenz.fl_calender.fl_add_to_calender_plus
//
//import io.flutter.embedding.engine.plugins.FlutterPlugin
//import io.flutter.plugin.common.MethodCall
//import io.flutter.plugin.common.MethodChannel
//import io.flutter.plugin.common.MethodChannel.MethodCallHandler
//import io.flutter.plugin.common.MethodChannel.Result
//
///** FlAddToCalenderPlusPlugin */
//class FlAddToCalenderPlusPlugin: FlutterPlugin, MethodCallHandler {
//  /// The MethodChannel that will the communication between Flutter and native Android
//  ///
//  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
//  /// when the Flutter Engine is detached from the Activity
//  private lateinit var channel : MethodChannel
//
//  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
//    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fl_add_to_calender_plus")
//    channel.setMethodCallHandler(this)
//  }
//
//  override fun onMethodCall(call: MethodCall, result: Result) {
//    if (call.method == "getPlatformVersion") {
//      result.success("Android ${android.os.Build.VERSION.RELEASE}")
//    } else {
//      result.notImplemented()
//    }
//  }
//
//  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//    channel.setMethodCallHandler(null)
//  }
//}


package com.fidenz.fl_calender.fl_add_to_calender_plus

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.CalendarContract
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.content.ContentResolver
import android.content.ContentValues
import java.text.SimpleDateFormat

/** FlAddToCalenderPlusPlugin */
class FlAddToCalenderPlusPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fl_add_to_calender_plus")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "getCalendarList") {
      val calendars = getCalendarList(context)
      result.success(calendars)

    } else if(call.method == "addEventToCalendar") {

      val title = call.argument<String>("title") ?: ""
      val description = call.argument<String>("description") ?: ""
      val startTime = call.argument<String>("startTime") ?: ""
      val endTime = call.argument<String>("endTime") ?: ""
      val timeZone = call.argument<String>("timeZone") ?: ""
      val location = call.argument<String>("location") ?: ""
      val calendarId = call.argument<String>("calendarId") ?: "0"

      addToDeviceCalendar(
        startTime,
        endTime,
        title,
        description,
        location,
        timeZone,
        calendarId,
        result
      )

    } else if(call.method == "updateEvent") {
      val eventId = call.argument<String>("eventId") ?: ""
      val title = call.argument<String>("title") ?: ""
      val description = call.argument<String>("description") ?: ""
      val startTime = call.argument<String>("startTime") ?: ""
      val endTime = call.argument<String>("endTime") ?: ""
      val timeZone = call.argument<String>("timeZone") ?: ""
      val location = call.argument<String>("location") ?: ""

      updateEvent(
        eventId,
        startTime,
        endTime,
        title,
        description,
        location,
        timeZone,
        result
      )
    } else {
      result.notImplemented()
    }
  }

  private fun getCalendarList(context: Context): List<Map<String, String>> {
    val deviceCalendars = mutableListOf<Map<String, String>>()
    val uniqueCalendars = mutableSetOf<String>()

    val cr: ContentResolver = context.contentResolver
    val cursor: Cursor?
    cursor = if (Build.VERSION.SDK.toInt() >= 8) cr.query(
      Uri.parse("content://com.android.calendar/calendars"),
      arrayOf(
        "_id",
        "calendar_displayName",
        "account_name",
        "calendar_color",
        "calendar_access_level"
      ),
      null,
      null,
      null
    ) else cr.query(
      Uri.parse("content://calendar/calendars"),
      arrayOf(
        "_id",
        "displayname",
        "account_name",
        "calendar_color",
        "calendar_access_level"
      ),
      null,
      null,
      null
    )

    if (cursor != null && cursor.moveToFirst()) {
      val calNames = arrayOfNulls<String>(cursor.getCount())
      val calIds = IntArray(cursor.getCount())
      for (i in calNames.indices) {
        calIds[i] = cursor.getInt(0)
        calNames[i] = cursor.getString(1)

        val calendarId = cursor.getString(0)
        val calendarDisplayName = cursor.getString(1)
        val calendarAccountName = cursor.getString(2)
        val calendarColor = cursor.getString(3)
        val calendarAccessLevel =
          cursor.getInt(cursor.getColumnIndexOrThrow("calendar_access_level"))

        val uniqueIdentifier = calendarAccountName
        if (calendarAccessLevel >= 700) {
          deviceCalendars.add(
            mapOf(
              "id" to calendarId,
              "display_name" to calendarDisplayName,
              "account_name" to calendarAccountName,
              "calendar_color" to calendarColor
            )
          )
        }
//                println("AVAILABLE CALENDAR : NAME = "+cursor.getString(1)+" id = "+cursor.getInt(0)+" ACCESS LEVEL = "+calendarAccessLevel+" ACCOUNT NAME = "+calendarAccountName)
        cursor.moveToNext()
      }
    }

    cursor?.close()
    if (cursor != null) {
      cursor.close()
    }
    return deviceCalendars
  }

  private fun updateEvent(
    eventId: String,
    startDate: String,
    endDate: String,
    title: String,
    description: String,
    location: String,
    timeZone: String,
    result: MethodChannel.Result
  ) {
    try {
      val cr: ContentResolver = context.contentResolver
      val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
      val startDate = sdf.parse(startDate).time
      val endDate = sdf.parse(endDate).time

      val updatedValues = ContentValues().apply {
        put("title", title)
        put("description", description)
        put("dtstart", startDate)
        put("dtend", endDate)
        put("hasAlarm", 1)
        put("eventTimezone", timeZone)
      }
      val updateUri: Uri = if (Build.VERSION.SDK_INT >= 8) {
        Uri.parse("content://com.android.calendar/events/$eventId")
      } else {
        Uri.parse("content://calendar/events/$eventId")
      }

      val rowsUpdated = cr.update(updateUri, updatedValues, null, null)
      if (rowsUpdated > 0) {
        result.success("Event updated successfully")
      } else {
        result.success("Event update failed")
      }
    } catch (e: Exception) {
      result.error("ERROR", e.message, null)
    }


  }

  private fun addToDeviceCalendar(
    startDate: String,
    endDate: String,
    title: String,
    description: String,
    location: String,
    timeZone: String,
    calendarId: String,
    result: MethodChannel.Result
  ) {
    try {
      val cr: ContentResolver = context.contentResolver
      val cv = ContentValues()

      val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
      val startDate = sdf.parse(startDate).time
      val endDate = sdf.parse(endDate).time

      cv.put("calendar_id", calendarId)
      cv.put("title", title)
      cv.put("dtstart", startDate)
      cv.put("hasAlarm", 1)
      cv.put("dtend", endDate)
      cv.put("eventTimezone", timeZone)


      val newEvent: Uri?
      newEvent = if (Build.VERSION.SDK.toInt() >= 8) cr.insert(
        Uri.parse("content://com.android.calendar/events"),
        cv
      ) else cr.insert(Uri.parse("content://calendar/events"), cv)

      if (newEvent != null) {
        val id = newEvent.lastPathSegment!!.toLong()
        val values = ContentValues()
        values.put("event_id", id)
        values.put("method", 1)
        values.put("minutes", 15) // 15 minutes
        if (Build.VERSION.SDK.toInt() >= 8) {
          cr.insert(
            Uri.parse("content://com.android.calendar/reminders"), values
          )
        } else {
          cr.insert(Uri.parse("content://calendar/reminders"), values)
        }
        result.success("$id")
      } else {
        result.error("ERROR", "Failed to add event to the calendar", null)
      }
    } catch (e: Exception) {
      result.error("ERROR", e.message, null)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

