//
//  SettingsView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 11/24/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import Contacts
import MessageUI

struct SettingsView: View {
    @State var isShowingContactUsScreen: Bool = false
    @State var mailResult: Result<MFMailComposeResult, Error>? = nil {
        didSet {
            isShowingContactUsScreen.toggle()
        }
    }
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Image("thanks_bg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blur(radius: 3.0)
                        .overlay(Color.gray.opacity(0.8))
                    VStack {
                        Image("banner_appicon")
                            .resizable()
                            .frame(width: 75, height: 75, alignment: .center)
                            .cornerRadius(15)
                        Text("Thank you for supporting SpeedBoard 😍")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                }.frame(height: 200, alignment: .center)


                Form {
                    if CNContactStore.authorizationStatus(for: .contacts) != .authorized {
                        Section {
                            SettingsRow(image: Image(systemName: "person.crop.circle.fill.badge.checkmark"), settingColor: .gray, glyphColor: .primary, settingText: "Grant Contact Access")
                        }
                        
                    }
                    Section {
                        Button(action: {
                            ReviewHelper.check()
                        }, label: {
                            SettingsRow(image: Image(systemName: "star.fill"), settingColor: .settingsAppStore, glyphColor: .white, settingText: "Rate SpeedBoard")
                        })
                        Button(action: {
                            isShowingContactUsScreen.toggle()
                        }, label: {
                            SettingsRow(image: Image(systemName: "envelope.fill"), settingColor: .settingsMail, glyphColor: .white, settingText: "Send Feedback")
                        })

                    }
                }
            }
            .navigationBarTitle(
                Text(Strings.title.rawValue),
                displayMode: .inline
            )
            .sheet(isPresented: $isShowingContactUsScreen, content: {
                MailView(isShowing: $isShowingContactUsScreen, result: $mailResult)
                    .navigationBarColor(backgroundColor: .primary, tintColor: .primary)
            })
        }

    }
}

struct SettingsRow: View {
    let image: Image?
    let settingColor: Color
    let glyphColor: Color
    let settingText: String
    
    
    var toggleState: Binding<Bool>?
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack {
                if image != nil {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(settingColor)
                        
                        if image != nil {
                            image!
                                .foregroundColor(glyphColor)
                                .shadow(radius: 10)
                                .scaleEffect(0.8)
                        }
                    }
                    .frame(width: 30, height: 30, alignment: .center)
                }
                Text(settingText)
                    .foregroundColor(Color("primaryText"))
            }
            
            Spacer()
            
            if toggleState != nil {
                Toggle(isOn: toggleState!, label: {
                    Color(.clear)
                        .frame(width: 0)
                })
                .labelsHidden()
            }
        }
    }
}

extension SettingsView {
    enum Strings: LocalizedStringKey {
        case title = "Settings_Title"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
