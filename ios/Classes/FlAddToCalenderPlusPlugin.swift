import Flutter
import UIKit
import EventKit

public class FlAddToCalenderPlusPlugin: NSObject, FlutterPlugin {

  private let eventStore = EKEventStore()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fl_add_to_calender_plus", binaryMessenger: registrar.messenger())
    let instance = FlAddToCalenderPlusPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "addEventToCalendar":
      guard let args = call.arguments as? [String: Any],
            let title = args["title"] as? String,
            let startDate = args["startTime"] as? String,
            let endDate = args["endTime"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing arguments", details: nil))
          return
      }

      requestAccessToCalendar { [weak self] granted in
          if granted {
              self?.addEventToCalendar(title: title, startDate: startDate, endDate: endDate, result: result)
          } else {
              result(FlutterError(code: "PERMISSION_DENIED", message: "Calendar permission denied", details: nil))
          }
      }

    case "updateEvent":
      guard let args = call.arguments as? [String: Any],
            let eventId = args["eventId"] as? String,
            let title = args["title"] as? String,
            let startDate = args["startTime"] as? String,
            let endDate = args["endTime"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing arguments", details: nil))
          return
      }

      requestAccessToCalendar { [weak self] granted in
          if granted {
              self?.updateEventInCalendar(eventId: eventId, title: title, startDate: startDate, endDate: endDate, result: result)
          } else {
              result(FlutterError(code: "PERMISSION_DENIED", message: "Calendar permission denied", details: nil))
          }
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestAccessToCalendar(completion: @escaping (Bool) -> Void) {
    eventStore.requestAccess(to: .event) { (granted, error) in
        if let error = error {
            print("Error requesting access: \(error.localizedDescription)")
            completion(false)
        } else {
            completion(granted)
        }
    }
  }

  private func addEventToCalendar(title: String, startDate: String, endDate: String, result: @escaping FlutterResult) {
    let event = EKEvent(eventStore: eventStore)
    event.title = title
    event.startDate = dateFromString(startDate)
    event.endDate = dateFromString(endDate)
    event.calendar = eventStore.defaultCalendarForNewEvents

    do {
        try eventStore.save(event, span: .thisEvent)
        result(event.eventIdentifier ?? "N/A")
    } catch let error {
        result(FlutterError(code: "ERROR", message: "Failed to add event: \(error.localizedDescription)", details: nil))
    }
  }

  private func updateEventInCalendar(eventId: String, title: String, startDate: String, endDate: String, result: @escaping FlutterResult) {
    if let event = eventStore.event(withIdentifier: eventId) {
        event.title = title
        event.startDate = dateFromString(startDate)
        event.endDate = dateFromString(endDate)

        do {
            try eventStore.save(event, span: .thisEvent)
            result("Event updated successfully")
        } catch let error {
            result(FlutterError(code: "ERROR", message: "Failed to update event: \(error.localizedDescription)", details: nil))
        }
    } else {
        result(FlutterError(code: "NOT_FOUND", message: "Event not found with ID: \(eventId)", details: nil))
    }
  }

  private func dateFromString(_ dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone.current
    if let date = dateFormatter.date(from: dateString) {
        print("Converted Date: \(date)")
        return date
    } else {
        print("Invalid date format, returning current date.")
        return Date()
    }
  }
}