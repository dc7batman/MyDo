//
//  EventDetailsViewController.swift
//  MyDo
//
//  Created by Mohan on 29/12/16.
//  Copyright © 2016 eventfy. All rights reserved.
//

import UIKit
import Crashlytics

class EventDetailsViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    
    let calendarHandler = CalendarHandler()
    var successActivities: [Activity]?
    
    
    var eventId : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        calendarView.scopeGesture.isEnabled = true
        calendarView.allowsMultipleSelection = true
        calendarView.swipeToChooseGesture.isEnabled = true
        calendarView.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        calendarView.appearance.selectionColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        calendarView.appearance.todayColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        updateCalendarSate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCalendarSate() {
        successActivities = DataModelManager.sharedInstance.successActivities(eventId: eventId!)
        if let activities = successActivities {
            for activity:Activity in activities {
                let date = activity.activityDate as Date?
                calendarView.select(date, scrollToDate: false)
            }
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return (calendarHandler.gregorian .compare(Date(), to: date, toUnitGranularity: .day) != .orderedAscending)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // add Activity
        DataModelManager.sharedInstance.addActivity(eventId: eventId!, isDone: true, date: date)
        
        Answers.logCustomEvent(withName: "Create Activity",
                               customAttributes: [
                                "Activity type" : "Done",
                                "Source" : "Calendar"])
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        DataModelManager.sharedInstance.addActivity(eventId: eventId!, isDone: false, date: date)
        
        Answers.logCustomEvent(withName: "Create Activity",
                               customAttributes: [
                                "Activity type" : "Skip",
                                "Source" : "Calendar"])
    }
    
    @IBAction func deleteEvent(_ sender: Any) {
        
        let alertController = UIAlertController.init(title: "Delete habit", message: "Deleting this will remove all your tracking information", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (_) in
            DataModelManager.sharedInstance.deleteEventWithId(eventId: self.eventId!)
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "mydo.deleteHabit"), object: nil, userInfo: nil))
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        present(alertController,animated: true)
    }
    
}
