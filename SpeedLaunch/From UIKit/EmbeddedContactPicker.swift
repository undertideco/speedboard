//
//  EmbeddedContactPicker.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 20/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import Contacts
import Combine

struct EmbeddedContactPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = EmbeddedContactPickerViewController
    var didSelectContact: ((CNContact) -> Void)
    var didCancelSelection: (() -> Void)

    final class Coordinator: NSObject, EmbeddedContactPickerViewControllerDelegate {
        
        var parent: EmbeddedContactPicker
        
        init(_ parent: EmbeddedContactPicker) {
            self.parent = parent
        }
        
        func embeddedContactPickerViewController(_ viewController: EmbeddedContactPickerViewController, didSelect contact: CNContact) {
            print("Selected Contact, \(contact)")
            parent.didSelectContact(contact)
        }

        func embeddedContactPickerViewControllerDidCancel(_ viewController: EmbeddedContactPickerViewController) {
            print("Cancelled Contact selection")
            parent.didCancelSelection()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<EmbeddedContactPicker>) -> EmbeddedContactPicker.UIViewControllerType {
        let result = EmbeddedContactPicker.UIViewControllerType()
        result.delegate = context.coordinator
        return result
    }

    func updateUIViewController(_ uiViewController: EmbeddedContactPicker.UIViewControllerType, context: UIViewControllerRepresentableContext<EmbeddedContactPicker>) { }

}
