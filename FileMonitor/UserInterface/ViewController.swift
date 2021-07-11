//
//  ViewController.swift
//  FileMonitor
//
//  Created by Hem Sharma on 10/07/21.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var tableView : NSTableView!
    private var directories : [String] = []
    private var monitorList : [DirectoryMonitor] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Start Observing
        guard let monitoredDirectories = MonitoredDirectoriesPersistentStoreHelper.readMonitoredDirectoryPathsFromPersistentStore() else{
            return
        }
        
        //Remove faults
        let faults = MonitoredDirectoriesSanityHelper.checkFaultsInMonitoredDirectoryList(directories: monitoredDirectories)
        for faultyDir in faults{
            MonitoredDirectoriesPersistentStoreHelper.deleteMonitoredDirectoryFromPersistentStore(directory: faultyDir)
        }
        directories = Array(Set(monitoredDirectories).subtracting(faults))
        
        if directories.count > 0 {
            tableView.reloadData()
            startMonitoring()
        }
    }
    
    private func checkAndfixCurrentStateOfMonitoredDirectories(directoryList : [String]) -> [String]{
        var fault = false
        var monitoredDirectories : [String] = []
        for directory in directoryList{
            var isDirectory : ObjCBool = false
            if !(FileManager.default.fileExists(atPath: directory, isDirectory: &isDirectory) && isDirectory.boolValue == true){
                //Directory moved or deleted
                MonitoredDirectoriesPersistentStoreHelper.deleteMonitoredDirectoryFromPersistentStore(directory: directory)
                fault = true
            }
        }
        if fault{
            monitoredDirectories = MonitoredDirectoriesPersistentStoreHelper.readMonitoredDirectoryPathsFromPersistentStore() ?? []
        }
        return monitoredDirectories
    }
    
    private func startMonitoring(){
        for directory in directories {
            if let directoryMonitor = DirectoryMonitor(url: URL.init(fileURLWithPath: directory)){
                monitorList.append(directoryMonitor)
                directoryMonitor.startMonitoring()
            }
        }
    }
    
    private func updateMonitoringList(urls : [URL]){
        for url in urls{
            var shouldMonitorDir = true
            for existingDir in self.directories{
                if url.path.contains(existingDir) {
                    print("Already monitoring parent directory")
                    shouldMonitorDir = false
                    break
                }
            }
            if shouldMonitorDir{
                self.directories.append(url.path)
                MonitoredDirectoriesPersistentStoreHelper.saveInPersistentStore(directoryPath: url.path)
            }
        }
        
        self.tableView.reloadData()
        self.startMonitoring()
    }
    
    @IBAction public func addDirectoryForMonitoring(sender : NSButton){
        let openPanel = NSOpenPanel()
        //We only want user to choose directories and not individual files.
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        openPanel.begin {[weak self] (response) in
            guard let self = self else{
                return
            }
            if response == .OK{
                let urls = openPanel.urls
                self.updateMonitoringList(urls: urls)
            }
        }
    }
    
    @IBAction public func removeDirectoryFromMonitoring(sender : NSButton){
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0, selectedRow < monitorList.count else {
            return
        }
        let directoryMonitor = monitorList[selectedRow]
        directoryMonitor.stopMonitoring()
        MonitoredDirectoriesPersistentStoreHelper.deleteMonitoredDirectoryFromPersistentStore(directory: directoryMonitor.directoryURL.path)
        directories.remove(at: selectedRow)
        monitorList.remove(at: selectedRow)
        tableView.reloadData()
    }
    
    @IBAction public func removeAllDirectoryFromMonitoring(sender : NSButton){
        for directoryMonitor in monitorList{
            directoryMonitor.stopMonitoring()
            MonitoredDirectoriesPersistentStoreHelper.deleteMonitoredDirectoryFromPersistentStore(directory: directoryMonitor.directoryURL.path)
        }
        monitorList.removeAll()
        directories.removeAll()
        tableView.reloadData()
    }
}

extension ViewController : NSTableViewDataSource{
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return directories.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return directories[row]
    }
}

