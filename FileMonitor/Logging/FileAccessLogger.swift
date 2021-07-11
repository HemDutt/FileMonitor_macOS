//
//  FileAccessLogger.swift
//  FileMonitor
//
//  Created by Hem Sharma on 10/07/21.
//

import Foundation

class FileAccessLogger : NSObject{
    
    static let sharedInstance = FileAccessLogger()
    private let serialQueue = DispatchQueue(label: "com.hem.fileacccess.loggerQueue")
    private let fileNameDateFormat = "yyyy-MM-dd"
    private let newLine = "\n\n"
    
    private lazy var logDirectory: URL? = {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        guard let appLogDirectoryURL = urls.last?.appendingPathComponent("com.hem.FileMonitor/AccessLogs") else{
            print("Can't get th application supoort directory path in user domain")
            return nil
        }
        
        if !FileManager.default.fileExists(atPath: appLogDirectoryURL.path){
            do{
                try FileManager.default.createDirectory(at: appLogDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError{
                print(error.localizedDescription);
            }
        }
        
        return appLogDirectoryURL
    }()
    
    private override init(){
        super.init()
    }
    
    private func logFilePath() -> String?{
        
        guard let logDirectory = self.logDirectory else {
            return nil
        }
        let fileName = String.init(format:"AccessLogs_%@.txt", Date().formattedString(format: fileNameDateFormat))
        let logFilePath = logDirectory.path.appendingFormat("/%@",fileName)
        if !FileManager.default.fileExists(atPath: logFilePath){
            FileManager.default.createFile(atPath: logFilePath, contents: nil, attributes: nil)
        }
        return logFilePath
    }
    
    public func logFileAccess(fileAccessLogModel:FileAccessLogModel)
    {
        serialQueue.sync {
            guard let logFilePath = self.logFilePath(), let fileHandle = FileHandle.init(forWritingAtPath: logFilePath) else {
                return
            }
            
            fileHandle.seekToEndOfFile()
            fileHandle.write(newLine.data(using: .utf8)!)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let data = try encoder.encode(fileAccessLogModel)
                fileHandle.write(data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
