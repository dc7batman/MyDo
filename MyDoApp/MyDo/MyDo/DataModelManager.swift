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
}
