//
//  URL.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/1/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation

extension URL {
    static var containerDocumentsDirectory: URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.co.undertide.speedboard")!
    }

    static func urlInDocumentsDirectory(with filename: String) -> URL {
        return containerDocumentsDirectory.appendingPathComponent(filename)
    }
}
