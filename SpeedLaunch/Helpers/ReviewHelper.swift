//
//  ReviewHelper.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 11/22/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation
import StoreKit

enum UserDefaultsKey: String {
    case significantUsageEventCount
    case significantUsageEventCountUntilPrompt
}

struct ReviewHelper {
    static var significantUsesUntilPrompt: Int {
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.significantUsageEventCountUntilPrompt.rawValue) }
        get { UserDefaults.standard.integer(forKey: UserDefaultsKey.significantUsageEventCountUntilPrompt.rawValue) }
    }
    
    fileprivate static var significantUsesCount: Int {
        set { UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.significantUsageEventCount.rawValue) }
        get { UserDefaults.standard.integer(forKey: UserDefaultsKey.significantUsageEventCount.rawValue) }
    }
    
    
    static func incrementSignificantUseCount(by count: Int = 1) {
        var eventCount = significantUsesCount
        eventCount += count
        
        significantUsesCount = eventCount
    }
    
    static func incrementSignificantUseThreshold(by count: Int = 3) {
        var significantUsesCount = significantUsesUntilPrompt
        significantUsesCount += count
        self.significantUsesCount = significantUsesCount
    }
    
    static func check() {
        if significantUsesCount >= significantUsesUntilPrompt {
            SKStoreReviewController.requestReview()
        }
    }
}
