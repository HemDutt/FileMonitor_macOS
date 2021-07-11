//
//  FileMonitor.swift
//  FileMonitor
//
//  Created by Hem Sharma on 10/07/21.
//

import Foundation

class FileMonitor {
    
    public let fileURL : URL
    
    private let source: DispatchSourceFileSystemObject
    private var state: FileMonitoringState = .off
    
    // Creates a folder monitor object with monitoring enabled.
    public init?(url: URL, eventMask : DispatchSource.FileSystemEvent, monitorinQueue : DispatchQueue, handler: @escaping (_ fileAcccessLogModel : FileAccessLogModel)->Void) {
        guard FileManager.default.fileExists(atPath: url.path) == true else {
            //File not present
            return nil
        }
        state = .off
        fileURL = url
        let descriptor = open(url.path, O_EVTONLY)
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: eventMask, queue: monitorinQueue)
        source.setEventHandler {[weak self] in
            guard let self = self else {
                return
            }
            let fileAccessLogModel = FileAccessLogModel(filePath: self.fileURL.path, accessTypes: self.source.accessType, user: NSUserName())
            handler(fileAccessLogModel)
        }
    }
    
    // Starts sending notifications if currently stopped
    public func startMonitoring() {
        if state == .off {
            state = .on
            source.resume()
        }
    }
    
    // Stops sending notifications if currently enabled
    public func stopMonitoring() {
        if state == .on {
            state = .off
            source.suspend()
        }
    }
    
    deinit {
        source.cancel()
    }
}
