//
//  String..swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 8/31/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation

public extension String {
    static let storeLocation = "actions.json"
    static let mediumWidgetActions = "medWidget.json"
    static let largeWidgetActions = "lgWidget.json"
    
    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }
}
