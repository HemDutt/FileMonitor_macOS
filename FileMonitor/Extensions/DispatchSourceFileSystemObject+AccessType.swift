//
//  DispatchSourceFileSystemObject+AccessType.swift
//  FileMonitor
//
//  Created by Hem Sharma on 10/07/21.
//

import Foundation

enum FileAccessTypes : String, Codable{
    case all        = "all"
    case attrib     = "attrib"
    case delete     = "delete"
    case extend     = "extend"
    case funlock    = "funlock"
    case link       = "link"
    case rename     = "rename"
    case revoke     = "revoke"
    case write      = "write"
}

extension DispatchSourceFileSystemObject {
    var accessType: [FileAccessTypes] {
        var accessTypeValues = [FileAccessTypes]()
        if data.contains(.all)      { accessTypeValues.append(.all) }
        if data.contains(.attrib)   { accessTypeValues.append(.attrib) }
        if data.contains(.delete)   { accessTypeValues.append(.delete) }
        if data.contains(.extend)   { accessTypeValues.append(.extend) }
        if data.contains(.funlock)  { accessTypeValues.append(.funlock) }
        if data.contains(.link)     { accessTypeValues.append(.link) }
        if data.contains(.rename)   { accessTypeValues.append(.rename) }
        if data.contains(.revoke)   { accessTypeValues.append(.revoke) }
        if data.contains(.write)    { accessTypeValues.append(.write) }
        return accessTypeValues
    }
}
