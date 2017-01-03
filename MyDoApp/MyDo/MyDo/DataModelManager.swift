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
        let currentDateStr = calendarHandler.formatter.string(from: Date())
        let currentDate = calendarHandler.formatter.date(from: currentDateStr)!
        let predicate = NSPredicate.init(format: "lastActivityDate < %@ OR lastActivityDate == nil", argumentArray: [currentDate])
        fetchRequest.predicate = predicate
        
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
    
    func deleteEventWithId(eventId: Int) {
        let moc = coreDataStack.mainMoc!
        if let event : Event = fetchEvent(eventId: eventId, moc: moc) {
            moc .delete(event)
            coreDataStack.doSaveMoc(moc: moc)
        }
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
    
    func fetchActivity(eventId: Int, date: Date, moc: NSManagedObjectContext) -> Activity? {
        
        let event: Event = fetchEvent(eventId: eventId, moc: moc)!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Activity")
        let predicate = NSPredicate.init(format: "event == %@ AND activityDate = %@", argumentArray: [event,date])
        fetchRequest.predicate = predicate
        
        var activities: [Activity]?
        do {
            activities = try moc.fetch(fetchRequest) as? Array<Activity>
        } catch {
            assert(false, "Fetching evets failed")
        }
        
        return activities?.first
    }
    
    func addActivity(eventId: Int, isDone: Bool) {
        addActivity(eventId: eventId, isDone: isDone, date: Date())
    }
    
    func addActivity(eventId: Int, isDone: Bool, date: Date) {
        let moc = coreDataStack.backgroundMoc!
        
        let event = fetchEvent(eventId: eventId, moc: moc)
        
        var activity: Activity?
        
        let activityType: Int = (isDone ? 1 : 0)
        
        let currentDateStr = calendarHandler.formatter.string(from: date)
        let currentDate : NSDate = calendarHandler.formatter.date(from: currentDateStr)! as NSDate
        
        if let a = fetchActivity(eventId: eventId, date: date, moc: moc) {
            activity = a
        } else {
            activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: moc) as? Activity
            activity?.activityDate = currentDate
        }
        
        activity?.activityType = Int16(activityType)
        
        event?.addToActivities(activity!)
        
        if calendarHandler.isToday(date: date) {
            event?.lastActivityDate = currentDate
        }
        
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
