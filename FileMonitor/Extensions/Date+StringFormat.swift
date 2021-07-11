//
//  Date+StringFormat.swift
//  FileMonitor
//
//  Created by Hem Sharma on 11/07/21.
//

import Foundation

extension Date
{
    func formattedString(format:String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let strDate = dateFormatter.string(from: self)
        return strDate
    }
}
