//
//  NSDateExtensions.swift
//  CodeMobile
//
//  Created by Louis Woods on 06/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import Foundation

extension Date {
    
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self as Date) == self.compare(date2 as Date)
    }
    func formatDate(dateToFormat: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let formattedDate = dateFormatter.date(from: dateToFormat )
        return formattedDate!
    }
    func wordedDate(Date: Date) -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a 'on' MMMM dd"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let dateString = formatter.string(from: Date)
        print(dateString)
        return dateString
    }
}
