//
//  MonitoredDirectoriesSanityHelper.swift
//  FileMonitor
//
//  Created by Hem Sharma on 12/07/21.
//

import Foundation

class MonitoredDirectoriesSanityHelper{
    
    static func checkFaultsInMonitoredDirectoryList(directories : [String]) -> [String]{
        var faults : [String] = []
        for directory in directories{
            var isDirectory : ObjCBool = false
            if !(FileManager.default.fileExists(atPath: directory, isDirectory: &isDirectory) && isDirectory.boolValue == true){
                //Directory moved or deleted
                faults.append(directory)
            }
        }
        return faults
    }
}
