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
    
    var selectedContact: CNContact?
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
    
    func incrementSignificantEventCountAndCheck() {
        ReviewHelper.incrementSignificantUseCount()
        ReviewHelper.check()
    }
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
        
        env.incrementSignificantEventCountAndCheck()
        
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
    var index: Int

    @State private var shouldShowImagePicker: Bool = false
    @State private var shouldShowPermissionsAlert = false
    @State private var customSelectedImage: UIImage? = nil
    
    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.selectedContact != nil {
                let selectedContact = viewStore.selectedContact!
                NavigationView {
                    Form {
                        Section {
                            GeometryReader { geo in
                                VStack(alignment: .center, spacing: 4) {
                                    ShortcutImageView(type: .empty, image: customSelectedImage ?? selectedContact.speedBoardActionImage)
                                        .frame(width: 80, height: 80)
                                    
                                    Button {
                                        shouldShowImagePicker = true
                                    } label: {
                                        Text("Edit")
                                            .font(.system(size: 16))
                                            .foregroundColor(.primary)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    
                                    Text("\(selectedContact.givenName) \(selectedContact.familyName)")
                                        .font(.system(size: 28))
                                }
                                .frame(width: geo.size.width, alignment: .center)
                                .fixedSize()
                            }
                            .accessibility(hidden: true)
                            .listRowBackground(Color(UIColor.secondarySystemBackground))
                            .frame(height: 150)
                        }


                        
                        ForEach(ActionType.allCases.dropLast(), id: \.self) { actionType in
                            Section {
                                ForEach(selectedContact.contactInformationArr, id: \.self) { contact in
                                    Button(action: {
                                        let compressedImage = UIImage.resize(image: customSelectedImage ?? selectedContact.speedBoardActionImage, targetSize: CGSize(width: 50, height: 50))
                                        let imageData = compressedImage.pngData()!
                                        
                                        if viewStore.isContactAccessAllowed {
                                            viewStore.send(
                                                .updateContactImage(selectedContact, imageData)
                                            )
                                        }
                                        
                                        viewStore.send(
                                            .addAction(selectedContact, actionType, index, contact.value, imageData)
                                        )
                                        
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
                .navigationViewStyle(StackNavigationViewStyle())
                .onAppear() {
                    shouldShowPermissionsAlert = !viewStore.isContactAccessAllowed
                }
                .present(isPresented: $shouldShowPermissionsAlert,
                         animation: .spring(response: 0.55, dampingFraction: 0.825, blendDuration: 0.1),
                         closeOnTap: true,
                         onTap: nil) {
                    
                    ContactPermissionsView(shouldShowPermissionsAlert: $shouldShowPermissionsAlert) {
                        viewStore.send(.requestContactBookPermission)
                    }
                    
                }
                .sheet(isPresented: $shouldShowImagePicker) {
                    ImagePicker(image: $customSelectedImage)
                }
            }
        }
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


extension CNContact {
    var speedBoardActionImage: UIImage {
        if let imageData = self.thumbnailImageData {
            return UIImage(data: imageData) ?? UIImage.generateWithName("\(self.givenName)")
        } else {
            return UIImage.generateWithName("\(self.givenName)")
        }
    }
}
