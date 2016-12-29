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
    
    func createEventWithName(name: String) -> Event {
        
        let moc = coreDataStack.backgroundMoc!
        
        let event: Event = NSEntityDescription.insertNewObject(forEntityName: "Event", into: moc) as! Event
        event.name = name
        event.createdDate = NSDate()
        event.eventId = 0
        
        moc.perform {
            self.coreDataStack.doSaveMoc(moc: moc)
        }
        
        return event
    }
}
