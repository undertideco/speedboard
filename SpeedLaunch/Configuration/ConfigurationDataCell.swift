//
//  ConfigurationDataCell.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import PhoneNumberKit

struct ConfigurationDataCell: View {
    let phoneNumberKit = PhoneNumberKit()
    let actionType: ActionType
    let label: String
    let value: String
    
    var dataLabel: String {
        do {
            let number = try phoneNumberKit.parse(value)
            let numberString = phoneNumberKit.format(number, toType: .international)
            return numberString
        } catch {
            return value
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(label)")
                    .foregroundColor(Color("primaryText"))
                Text("\(dataLabel)")
                    .foregroundColor(Color.primary)
            }
            Spacer()
            
            switch actionType {
            case .call:
                Image(systemName: "phone")
                    .font(.system(size: 22))
                    .foregroundColor(Color.primary)
            case .message:
                Image(systemName: "message")
                    .font(.system(size: 22))
                    .foregroundColor(Color.primary)
            case .facetime:
                Image(systemName: "video")
                    .font(.system(size: 22))
                    .foregroundColor(Color.primary)
            default:
                Color.clear
            }
        }
    }
}

struct ConfigurationDataCell_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationDataCell(actionType: .call, label: "iPhone", value: "+65 9123 4567")
            .background(Color.gray)
            .frame(width: 343)
    }
}
