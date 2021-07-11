//
//  MonitoredDirectoriesPersistentStoreHelper.swift
//  FileMonitor
//
//  Created by Hem Sharma on 11/07/21.
//

import Cocoa

class MonitoredDirectoriesPersistentStoreHelper{
    
    static func saveInPersistentStore(directoryPath: String) {
      
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "MonitoredDirectories", in: managedContext)!
        let directory = NSManagedObject(entity: entity, insertInto: managedContext)
        directory.setValue(directoryPath, forKey: "directory")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func readMonitoredDirectoryPathsFromPersistentStore() -> [String]? {
      
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        var monitoredDirectories : [String]?
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MonitoredDirectories")
        
        do {
            let monitoredDirectoriesModel = try managedContext.fetch(fetchRequest)
            monitoredDirectories = monitoredDirectoriesModel.map({ (directory) -> String in
                return directory.value(forKeyPath: "directory") as! String
            })
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return monitoredDirectories
    }
    
    static func deleteMonitoredDirectoryFromPersistentStore(directory : String) {
      
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MonitoredDirectories")
        fetchRequest.predicate = NSPredicate.init(format: "directory = \"\(directory)\"")
        
        do {
            let monitoredDirectoryModels = try managedContext.fetch(fetchRequest)
            for model in monitoredDirectoryModels {
                managedContext.delete(model)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
}

