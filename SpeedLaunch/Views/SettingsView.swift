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
import ComposableArchitecture
import Dependencies

struct SettingsViewState: Equatable {
    var shouldShowSystemContactPermissionsAlert = false
    var isContactAccessAllowed: Bool = CNContactStore.authorizationStatus(for: .contacts) == .authorized
}

enum SettingsViewAction: Equatable {
    case requestContactBookPermission
    case didChangeContactBookPermission(Result<Bool, ContactsError>)
    case showPermissionsAlert(Bool)
}


struct SettingsViewReducer: Reducer {
    typealias State = SettingsViewState
    typealias Action = SettingsViewAction
    
    @Dependency(\.contactBookClient) var contactBookClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
    switch action {
    case .requestContactBookPermission:
        return contactBookClient.requestContactBookPermission()
            .map { success in SettingsViewAction.didChangeContactBookPermission(.success(success)) }
    case let .didChangeContactBookPermission(.success(completion)):
        state.isContactAccessAllowed = completion
        return .none
    case let .showPermissionsAlert(show):
        state.shouldShowSystemContactPermissionsAlert = show
        return .none
    default:
        return .none
    }
        }
    }
}

struct SettingsView: View {
    var store: Store<SettingsViewState, SettingsViewAction>
    @State private var isShowingContactUsScreen: Bool = false
    @State private var shouldShowPermissionsAlert = false

    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil {
        didSet {
            isShowingContactUsScreen.toggle()
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                        if !viewStore.isContactAccessAllowed {
                            Section {
                                Button(action: {
                                    shouldShowPermissionsAlert = true
                                }, label: {
                                    SettingsRow(image: Image(systemName: "person.crop.circle.fill.badge.checkmark"), settingColor: .settingsContactsAuth, glyphColor: .white, settingText: "Grant Contact Access")
                                })
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
                .present(isPresented: $shouldShowPermissionsAlert,
                         animation: .spring(response: 0.55, dampingFraction: 0.825, blendDuration: 0.1),
                         closeOnTap: true,
                         onTap: nil) {
                    
                    ContactPermissionsView(shouldShowPermissionsAlert: viewStore.binding(get: \.shouldShowSystemContactPermissionsAlert, send: SettingsViewAction.showPermissionsAlert)) {
                        viewStore.send(.requestContactBookPermission)
                    }
                    
                }
                .sheet(isPresented: $isShowingContactUsScreen, content: {
                    MailView(isShowing: $isShowingContactUsScreen, result: $mailResult)
                        .navigationBarColor(backgroundColor: .primary, tintColor: .primary)
                })
            }
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
        SettingsView(store: Store(initialState: SettingsViewState()) { SettingsViewReducer() })
    }
}
