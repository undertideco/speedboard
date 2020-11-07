//
//  ConfigurationView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 20/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import LetterAvatarKit
import Contacts
import Combine
import ComposableArchitecture

struct ConfigurationState: Equatable {
    static func == (lhs: ConfigurationState, rhs: ConfigurationState) -> Bool {
        return lhs._isContactsAccessAllowed == rhs._isContactsAccessAllowed
    }
    
    var isContactAccessAllowed: Bool {
        get { return _isContactsAccessAllowed ?? false }
        set { _isContactsAccessAllowed = newValue }
    }
    @DocDirectoryBacked<Bool>(location: .storeLocation) var _isContactsAccessAllowed
}

enum ConfigurationAction : Equatable {
    case addAction(CNContact, ActionType, Int, String, Data)
    case updateContactImage(CNContact, Data)
    
    case requestContactBookPermission
    
    case didAddAction(Result<Action, PersistenceError>)
    case didUpdateContactImage(Result<Bool, ContactsError>)
    case didChangeContactBookPermission(Result<Bool, ContactsError>)
}

struct ConfigurationEnvironment {    
    var storageClient: StorageClient
    var contactBookClient: ContactBookClient
}

enum ActiveConfigurationSheet {
    case contacts, photo
}

let configurationReducer = Reducer<ConfigurationState, ConfigurationAction, ConfigurationEnvironment> { state, action, env in
    switch action {
    
    case let .addAction(contact, type, position, number, imageData):
        let action = Action(
            id: UUID(),
            type: type,
            contactValue: number,
            imageData: imageData,
            createdTime: Date(),
            actionName: contact.givenName,
            contactBookIdentifier: contact.identifier
        )
        
        return env.storageClient.saveAction(action)
            .catchToEffect()
            .map(ConfigurationAction.didAddAction)
            .eraseToEffect()
    case let .updateContactImage(contact, imageData):
        return env.contactBookClient.saveNewContactImage(imageData, contact)
            .catchToEffect()
            .map(ConfigurationAction.didUpdateContactImage)
            .eraseToEffect()
    case .requestContactBookPermission:
        return env.contactBookClient.requestContactBookPermission()
            .catchToEffect()
            .map(ConfigurationAction.didChangeContactBookPermission)
            .eraseToEffect()
    case let .didChangeContactBookPermission(.success(completion)):
        state.isContactAccessAllowed = completion
        return .none
    default:
        return .none
    }
}

struct ConfigurationView: View {
    var store: Store<ConfigurationState, ConfigurationAction>
    let selectedContact: CNContact
    var selectedContactImage: UIImage {
        if let imageData = selectedContact.thumbnailImageData {
            return  UIImage(data: imageData) ?? UIImage.generateWithName("\(selectedContact.givenName)")
        } else {
            return UIImage.generateWithName("\(selectedContact.givenName)")
        }
    }
    
    var index: Int
    var onDismiss: (() -> Void)?
    var selectedContactHasImage: Bool {
        return selectedContact.thumbnailImageData != nil
    }
        
    @State private var activeSheet: ActiveConfigurationSheet = .contacts
    @State private var shouldShowPermissionsAlert = false
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    GeometryReader { geo in
                        VStack(alignment: .center) {
                            ShortcutImageView(type: .empty, image: selectedContactImage)
                                .frame(width: 80, height: 80)
                            
                            Text(selectedContact.givenName)
                                .font(.system(size: 31))
                        }
                        .frame(width: geo.size.width, alignment: .center)
                        .fixedSize()
                    }
                    .accessibility(hidden: true)
                    .listRowBackground(Color(UIColor.secondarySystemBackground))
                    .frame(height: 130)

                    
                    ForEach(ActionType.allCases.dropLast(), id: \.self) { actionType in
                        Section {
                            ForEach(selectedContact.contactInformationArr, id: \.self) { contact in
                                Button(action: {
                                    let compressedImage = UIImage.resize(image: selectedContactImage, targetSize: CGSize(width: 50, height: 50))
                                    let imageData = compressedImage.pngData()!
                                    
                                    if viewStore.isContactAccessAllowed {
                                        viewStore.send(.updateContactImage(selectedContact, imageData))
                                    }
                                    
                                    viewStore.send(
                                        .addAction(selectedContact, actionType, index, contact.value, imageData)
                                    )
                                    
                                    self.onDismiss?()
                                }) {
                                    ConfigurationDataCell(actionType: actionType, label: contact.label, value: contact.value)
                                        .frame(height: 50)
                                }
                                .accessibilityElement()
                                .accessibility(label: Text("\(contact.value)"))
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibility(label: Text(Strings.actionHeadings(actionType).value))
                    }
                }
                .navigationBarTitle(
                    Text(Strings.title.value),
                    displayMode: .inline
                )
                .accessibility(label: Text(Strings.formLabel.value))
                .accessibility(hint: Text(Strings.formHint.value))
            }
            .onAppear() {
                shouldShowPermissionsAlert = !viewStore.isContactAccessAllowed
            }
            .present(isPresented: $shouldShowPermissionsAlert,
                     animation: .spring(response: 0.55, dampingFraction: 0.825, blendDuration: 0.1),
                     closeOnTap: true,
                     onTap: nil) {
                
                createContactPermissionsView(store: viewStore)
            }
        }
    }
    
    func createContactPermissionsView(store: ViewStore<ConfigurationState, ConfigurationAction>) -> some View {
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
                store.send(.requestContactBookPermission)
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

extension ConfigurationView {
    enum Strings {
        case title
        case formLabel
        case formHint
        case actionHeadings(ActionType)
        
        var value: LocalizedStringKey {
            switch self {
            case .title:
                return "Configuration_Title"
            case .actionHeadings(let actionType):
                let actionLocalized = actionType.localizedStringKey().localized()
                
                return "ConfigurationView_Action_Heading \(actionLocalized)"
            case .formLabel:
                return "ConfigurationView_Form_Label"
            case .formHint:
                return "ConfigurationView_Form_Hint"
            }
        }
    }
}
