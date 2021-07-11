//
//  FileAccessModels.swift
//  FileMonitor
//
//  Created by Hem Sharma on 11/07/21.
//

import Foundation

public struct FileAccessLogModel : Codable{
    private var timeStamp = Date().formattedString(format: "yyyy-mm-dd hh-mm-ss.sss")
    let filePath : String
    let accessTypes : [FileAccessTypes]
    let user : String
    
    enum CodingKeys : String, CodingKey {
        case timeStamp = "timeStamp"
        case filePath = "filePath"
        case accessTypes = "accessTypes"
        case user = "user"
    }
    
    init(filePath: String, accessTypes: [FileAccessTypes], user: String) {
        self.filePath = filePath
        self.accessTypes = accessTypes
        self.user = user
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timeStamp = try values.decode(String.self, forKey: .timeStamp)
        filePath = try values.decode(String.self, forKey: .filePath)
        accessTypes = try values.decode([FileAccessTypes].self, forKey: .accessTypes)
        user = try values.decode(String.self, forKey: .user)
    }
}

public enum FileMonitoringState {
    case on, off
}
