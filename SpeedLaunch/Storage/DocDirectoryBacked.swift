//
//  DocDirectoryBacked.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 15/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation

@propertyWrapper struct DocDirectoryBacked<Value: Codable> {
    let location: String
    let documentDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.co.undertide.speedboard")!
    
    private var dirToSave: URL {
        return documentDirectory.appendingPathComponent("\(location)")
    }
    
    var wrappedValue: Value? {
        get {
            do {
                let data = try Data(contentsOf: dirToSave)
                return try JSONDecoder().decode(Value.self, from: data)
            } catch {
                return nil
            }
        }
        
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                try data.write(to: dirToSave)
                print("wrote data: \(newValue) in: \(dirToSave)")
            } catch {
                print("Error saving to \(dirToSave)")
            }
        }
    }
}
