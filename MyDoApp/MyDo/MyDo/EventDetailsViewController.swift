//
//  EventDetailsViewController.swift
//  MyDo
//
//  Created by Mohan on 29/12/16.
//  Copyright © 2016 eventfy. All rights reserved.
//

import UIKit
import Crashlytics

class EventDetailsViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {

    @IBOutlet weak var calendarView: FSCalendar!
    
    let calendarHandler = CalendarHandler()
    var allActivities: [Activity]?
    
    
    var eventId : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        allActivities = DataModelManager.sharedInstance.allActivities(eventId: eventId!)
        
        calendarView.scopeGesture.isEnabled = false
        calendarView.allowsMultipleSelection = true
        calendarView.swipeToChooseGesture.isEnabled = true
        calendarView.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        calendarView.appearance.todayColor = UIColor.darkGray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return (calendarHandler.gregorian .compare(Date(), to: date, toUnitGranularity: .day) != .orderedAscending)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // add Activity
        let activity: Activity = DataModelManager.sharedInstance.addActivity(eventId: eventId!, isDone: true, date: date)!
        allActivities?.append(activity)
        
        Answers.logCustomEvent(withName: "Create Activity",
                               customAttributes: [
                                "Activity type" : "Done",
                                "Source" : "Calendar"])
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let activity: Activity = DataModelManager.sharedInstance.addActivity(eventId: eventId!, isDone: false, date: date)!
        allActivities?.append(activity)
        Answers.logCustomEvent(withName: "Create Activity",
                               customAttributes: [
                                "Activity type" : "Skip",
                                "Source" : "Calendar"])
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if let activities = allActivities {
            for activity:Activity in activities {
                let actDate = activity.activityDate as Date?
                if calendarHandler.gregorian.isDate(actDate!, inSameDayAs: date) {
                    if activity.activityType == 1 {
                        return #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                    } else {
                        return UIColor.red
                    }
                }
            }
        }
        return UIColor.clear
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
