//
//  AlertView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 11/1/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct AlertView<AlertContent>: ViewModifier where AlertContent : View {
    
    /// Tells if the sheet should be presented or not
    @Binding var isPresented: Bool
    
    var animation: Animation
    
    var closeOnTap: Bool
    var handleTap: () -> Void

    var view: () -> AlertContent

    // MARK: - Private Properties
        
    /// The rect of the hosting controller
    @State private var presenterContentRect: CGRect = .zero
    
    /// The rect of popup content
    @State private var sheetContentRect: CGRect = .zero
    
    /// The offset when the popup is hidden
    private var hiddenOffset: CGFloat {
        return UIScreen.main.bounds.size.height - presenterContentRect.midY + sheetContentRect.height/2 + 5
    }
    
    private var presentedOffset: CGFloat {
        return -presenterContentRect.midY + UIScreen.main.bounds.size.height / 2
    }
    
    /// The current offset, based on the **presented** property
    private var currentOffset: CGFloat {
        return isPresented ? presentedOffset : hiddenOffset
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    let rect = proxy.frame(in: .global)
                    // This avoids an infinite layout loop
                    if rect.integral != self.presenterContentRect.integral {
                        DispatchQueue.main.async {
                            self.presenterContentRect = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
            .overlay(sheet())
    }
    
    func sheet() -> some View {
        return ZStack {
            Group {
                VStack {
                    VStack {
                        self.view()
                            .simultaneousGesture(TapGesture().onEnded{
                                if closeOnTap {
                                    self.isPresented = false
                                    self.handleTap()
                                }
                            })
                            .background(
                                GeometryReader { proxy -> AnyView in
                                    let rect = proxy.frame(in: .global)
                                    // This avoids an infinite layout loop
                                    if rect.integral != self.sheetContentRect.integral {
                                        DispatchQueue.main.async {
                                            self.sheetContentRect = rect
                                        }
                                    }
                                    return AnyView(EmptyView())
                                }
                            )
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width)
                .offset(x: 0, y: currentOffset)
                .scaleEffect(isPresented ? 1.0 : 0)
                .animation(animation)
            }
        }
    }
}

extension View {
    func present<AlertContent: View>(
        isPresented: Binding<Bool>,
        animation: Animation = Animation.easeOut(duration: 0.3),
        closeOnTap: Bool = true,
        onTap: (() -> Void)? = nil,
        view: @escaping () -> AlertContent) -> some View {
        self.modifier(
            AlertView(
                isPresented: isPresented,
                animation: animation,
                closeOnTap: closeOnTap,
                handleTap: onTap ?? {},
                view: view
            )
        )
    }
}
