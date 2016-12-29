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
    
    func createEvent(name: String) {
        
    }
    
    func fetchTodayEvents() -> Array<Event> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Event")
        let currentDateStr = calendarHandler.formatter.string(from: Date())
        let currentDate = calendarHandler.formatter.date(from: currentDateStr)!
        let predicate = NSPredicate.init(format: "lastActivityDate != %@", argumentArray: [currentDate])
        fetchRequest.predicate = predicate
        
        var events : Array<Event> = [];
        do {
            events = try coreDataStack.mainMoc?.fetch(fetchRequest) as! Array<Event>
        } catch {
            assert(false, "Fetching evets failed")
        }
        
        return events
    }
}
