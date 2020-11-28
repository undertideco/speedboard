//
//  ContactPermissionsView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 11/27/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ContactPermissionsView: View {
    @Binding var shouldShowPermissionsAlert: Bool
    var onRequest: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "book.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.primary)
            Text("Contacts Access Needed")
                .font(.system(size: 24, weight: .regular, design: .default))
                .multilineTextAlignment(.center)
            Text("We only use your contact book's information to automatically update action images")
                .font(.system(.subheadline))
                .multilineTextAlignment(.center)
            Button(action: {
                print("request permission")
                onRequest?()
            }, label: {
                ZStack {
                    Text("Allow")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                }
                .background(Color.blue)
                .cornerRadius(20)
            })
            Button(action: {
                self.shouldShowPermissionsAlert = false
            }, label: {
                Text("Not now")
                    .font(.system(size: 14, weight: .regular, design: .default))
            })
        }
        .padding(EdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 20))
        .frame(width: 350, height: 300)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10.0)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
    }
}
