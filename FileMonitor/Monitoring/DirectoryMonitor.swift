//
//  DirectoryMonitor.swift
//  FileMonitor
//
//  Created by Hem Sharma on 10/07/21.
//

import Foundation

class DirectoryMonitor {
    
    public let directoryURL: URL

    private let fileMonitorQueue: DispatchQueue
    private let directoryMonitorQueue: DispatchQueue
    private let source: DispatchSourceFileSystemObject
    private var fileMonitorList: [FileMonitor]
    private var state: FileMonitoringState = .off
    private var waitTimer : Timer?

    init?(url:URL){
        
        var isDirectory : ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            return nil
        }
        
        directoryURL = url
        fileMonitorList = []
        fileMonitorQueue = DispatchQueue.global()
        
        //Monitor directory for write operations to get notified about directory structure
        let descriptor = open(directoryURL.path, O_EVTONLY)
        directoryMonitorQueue = DispatchQueue.global()
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: .write, queue: directoryMonitorQueue)
        source.setEventHandler {[weak self] in
            guard let self = self else {
                return
            }
            self.changeInDirectoryStructureNotified()
        }
    }
    
    private func changeInDirectoryStructureNotified(){
        //Added or Deleted file inside folder
        //For multiple file add or delete, there will be multiple notifications
        //We do not want to do any operation till directory structure gets stable
        DispatchQueue.main.async {
            self.waitTimer?.invalidate()
            self.waitTimer = nil
            self.waitTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.handleChangeInDirectoryStructure(timer:)), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func handleChangeInDirectoryStructure(timer : Timer){
        //Restart monitoring
        stopMonitoring()
        fileMonitorList.removeAll()
        startMonitoring()
    }
    
    private func monitorChildDirectory(url : URL){
        let fileMonitor = FileMonitor.init(url: url, eventMask: .write, monitorinQueue: fileMonitorQueue) { (fileAccessLogModel) in
            //Directory restructured
            self.changeInDirectoryStructureNotified()
        }
        if fileMonitor != nil{
            fileMonitorList.append(fileMonitor!)
            fileMonitor!.startMonitoring()
        }
    }
    
    private func monitorFile(url : URL){
        let fileMonitor = FileMonitor.init(url: url, eventMask: .all, monitorinQueue: fileMonitorQueue) { (fileAccessLogModel) in
            //Log File access
            FileAccessLogger.sharedInstance.logFileAccess(fileAccessLogModel: fileAccessLogModel)
        }
        if fileMonitor != nil{
            fileMonitorList.append(fileMonitor!)
            fileMonitor!.startMonitoring()
        }
    }
    
    func startMonitoring(){
        guard state == .off else {
            //Already monitoring
            return
        }
        state = .on
        source.resume()
        
        //Monitor internal structure
        let enumerator = FileManager.default.enumerator(atPath: directoryURL.path)
        while let element = enumerator?.nextObject() as? String {
            if let fileType = enumerator?.fileAttributes?[FileAttributeKey.type] as? FileAttributeType{
                switch fileType{
                case .typeRegular:
                    //File. Add Observer
                    self.monitorFile(url: directoryURL.appendingPathComponent(element))
                case .typeDirectory:
                    //Directory. Add Observer
                    self.monitorChildDirectory(url: directoryURL.appendingPathComponent(element))
                default:
                    break
                }
            }
        }
    }
    
    // Stops sending notifications if currently enabled
    public func stopMonitoring() {
        guard state == .on else {
            //Not monitoring anyway
            return
        }
        state = .off
        self.waitTimer?.invalidate()
        self.waitTimer = nil
        source.suspend()
        for fileMonitor in fileMonitorList {
            fileMonitor.startMonitoring()
        }
    }
    
    deinit {
        self.stopMonitoring()
        source.cancel()
    }
}
