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

enum ActiveConfigurationSheet {
    case contacts, photo
}

struct ConfigurationView: View {
    var store: Store<AppState, AppAction>
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
        
    
    @State private var activeSheet: ActiveConfigurationSheet = .contacts

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
                        .accessibilityElement()
                        .accessibility(label: Text("\(selectedContact.givenName)"))
                        .frame(width: geo.size.width, alignment: .center)
                        .fixedSize()
                    }
                    .listRowBackground(Color(UIColor.secondarySystemBackground))
                    .frame(height: 130)

                    
                    ForEach(ActionType.allCases.dropLast(), id: \.self) { actionType in
                        Section {
                            ForEach(selectedContact.contactInformationArr, id: \.self) { contact in
                                Button(action: {
                                    let compressedImage = UIImage.resize(image: selectedContactImage, targetSize: CGSize(width: 50, height: 50))
                                    let imageData = compressedImage.pngData()!
                                    
                                    viewStore.send(.addAction(actionType, selectedContact.givenName, index, contact.value, imageData))
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
                .navigationBarTitle(Text(Strings.title.value), displayMode: .inline)
                .accessibility(label: Text(Strings.formLabel.value))
                .accessibility(hint: Text(Strings.formHint.value))
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
