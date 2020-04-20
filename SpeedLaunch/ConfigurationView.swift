//
//  ConfigurationView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 20/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import Contacts

struct ConfigurationView: View {
    @State private var user = ""
    @State private var isShowingContactSelector = false
    @State private var selectedContact: CNContact? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Button(action: {
                    self.isShowingContactSelector = true
                }) { Text("Select a Contact") }
            }.navigationBarTitle(Text("Configure Action"))
        }.sheet(isPresented: $isShowingContactSelector) {
            EmbeddedContactPicker(didSelectContact: { contact in
                self.selectedContact = contact
                self.isShowingContactSelector = false
            }) {
                self.isShowingContactSelector = false
            }
        }
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}
