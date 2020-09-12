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
                            }
                        }
                    }
                }
                .navigationBarTitle(Text(Strings.title.rawValue), displayMode: .inline)
            }
        }
    }
}


// Strings
extension ConfigurationView {
    enum Strings: LocalizedStringKey {
        case title = "Configuration_Title"
    }
}
