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
}
