//
//  CalendarHandler.swift
//  MyDo
//
//  Created by Mohan on 29/12/16.
//  Copyright © 2016 eventfy. All rights reserved.
//

import UIKit

class CalendarHandler: NSObject {
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    private let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
}
