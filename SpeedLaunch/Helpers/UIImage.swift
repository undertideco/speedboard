//
//  UIImage.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import UIKit
import LetterAvatarKit


extension UIImage {
    static func generateWithName(_ name: String) -> UIImage {
        return  LetterAvatarMaker()
                    .setCircle(true)
                    .setUsername(name)
                    .build()!
    }
}
