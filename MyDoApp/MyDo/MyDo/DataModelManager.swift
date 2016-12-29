//
//  DataModelManager.swift
//  MyDo
//
//  Created by Mohan on 29/12/16.
//  Copyright © 2016 eventfy. All rights reserved.
//

import UIKit
import CoreData

class DataModelManager: NSObject {
    
    let calendarHandler = CalendarHandler()
    let coreDataStack = CoredataStack.init()
    
    static let sharedInstance : DataModelManager = {
        let instance = DataModelManager.init()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    func fetchTodayEvents() -> Array<Event> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Event")
//        let currentDateStr = calendarHandler.formatter.string(from: Date())
//        let currentDate = calendarHandler.formatter.date(from: currentDateStr)!
//        let predicate = NSPredicate.init(format: "lastActivityDate < %@ OR lastActivityDate == nil", argumentArray: [currentDate])
//        fetchRequest.predicate = predicate
        
        var events : Array<Event> = [];
        do {
            events = try coreDataStack.mainMoc?.fetch(fetchRequest) as! Array<Event>
        } catch {
            assert(false, "Fetching evets failed")
        }
        
        return events
    }
    
    func fetchEvent(eventId: Int, moc: NSManagedObjectContext) -> Event? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Event")
        let predicate = NSPredicate.init(format: "eventId == %d", argumentArray: [eventId])
        fetchRequest.predicate = predicate
        
        var events : Array<Event> = [];
        do {
            events = try moc.fetch(fetchRequest) as! Array<Event>
        } catch {
            assert(false, "Fetching evets failed")
        }
        
        return events.first
    }
    
    func maxEventId() -> Int {
        
        var maxId = 0
        
        let moc = coreDataStack.backgroundMoc!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Event")
        fetchRequest.resultType = .dictionaryResultType
        
        let keyPathExpression = NSExpression.init(forKeyPath: "eventId")
        let maxIdExpression = NSExpression.init(forFunction: "max:", arguments: [keyPathExpression])
        
        let expressionDiscription = NSExpressionDescription.init()
        expressionDiscription.name = "maxEventId"
        expressionDiscription.expression = maxIdExpression
        expressionDiscription.expressionResultType = .integer16AttributeType
        fetchRequest.propertiesToFetch = [expressionDiscription]
        
        var result: Array<Any> = []
        
        do {
            result = try moc.fetch(fetchRequest)
        } catch {
            assert(false, "Fetching max event id failed")
        }
        
        let dict: Dictionary = (result.first as? [String : Int])!
        maxId = dict["maxEventId"]!
        
        return maxId
    }
    
    func createEventWithName(name: String) -> Event {
        
        let moc = coreDataStack.backgroundMoc!
        
        let event: Event = NSEntityDescription.insertNewObject(forEntityName: "Event", into: moc) as! Event
        event.name = name
        event.createdDate = NSDate()
        event.eventId = maxEventId()+1
        
        moc.perform {
            self.coreDataStack.doSaveMoc(moc: moc)
        }
        
        return event
    }
    
    func addActivity(eventId: Int, isDone: Bool) {
        
        let moc = coreDataStack.backgroundMoc!
        
        let event = fetchEvent(eventId: eventId, moc: moc)
        
        let activity: Activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: moc) as! Activity
        activity.activityType = (isDone ? 1 : 0)
        let currentDateStr = calendarHandler.formatter.string(from: Date())
        let currentDate : NSDate = calendarHandler.formatter.date(from: currentDateStr)! as NSDate
        activity.activityDate = currentDate
        
        event?.addToActivities(activity)
        event?.lastActivityDate = currentDate
        
        moc.perform {
            self.coreDataStack.doSaveMoc(moc: moc)
        }
    }
    
    func addActivity(eventId: Int, isDone: Bool, date: Date) {
        let moc = coreDataStack.backgroundMoc!
        
        let event = fetchEvent(eventId: eventId, moc: moc)
        
        let activity: Activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: moc) as! Activity
        activity.activityType = (isDone ? 1 : 0)
        let currentDateStr = calendarHandler.formatter.string(from: date)
        let currentDate : NSDate = calendarHandler.formatter.date(from: currentDateStr)! as NSDate
        activity.activityDate = currentDate
        
        event?.addToActivities(activity)
        event?.lastActivityDate = currentDate
        
        moc.perform {
            self.coreDataStack.doSaveMoc(moc: moc)
        }
    }
    
    func successActivities(eventId: Int) -> Array<Activity>? {
        
        var successActivities: [Activity]?
        let moc = coreDataStack.mainMoc!
        
        if let event: Event = fetchEvent(eventId: eventId, moc: moc) {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Activity")
            let predicate = NSPredicate.init(format: "event == %@ AND activityType = %d", argumentArray: [event,1])
            fetchRequest.predicate = predicate
            
            do {
                successActivities = try moc.fetch(fetchRequest) as? Array<Activity>
            } catch {
                assert(false, "Fetching evets failed")
            }
            
        }
        
        return successActivities
    }
}
