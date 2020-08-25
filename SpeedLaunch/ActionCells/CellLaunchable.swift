//
//  CellLaunchable.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 25/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

protocol Launchable: View {
    associatedtype CellDataType
    
    var handlePressed: ((CellDataType) -> Void)? { get set }
}
