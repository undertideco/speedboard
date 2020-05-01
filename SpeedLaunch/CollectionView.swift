//
//  CollectionView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 30/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct CollectionView<Elements, Content>: View where Elements: RandomAccessCollection, Content: View, Elements.Element: Identifiable {
    var data: Elements
    var layout: (Elements, CGSize, [Elements.Element.ID: CGSize]) -> [Elements.Element.ID: CGSize]
    var content: (Elements.Element?) -> Content
    @State private var sizes: [Elements.Element.ID: CGSize] = [:]
    
    private func bodyHelper(containerSize: CGSize, offsets: [Elements.Element.ID: CGSize]) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(data) {
                PropagateSize(content: self.content($0), id: $0.id)
                    .offset(offsets[$0.id] ?? CGSize.zero)
                    .animation(.default)
            }
            Color.clear
                .frame(width: containerSize.width, height: containerSize.height)
                .fixedSize()
        }.onPreferenceChange(CollectionViewSizeKey.self) {
            self.sizes = $0
            
        }.background(Color.red)
    }
    
    var body: some View {
        GeometryReader { proxy in
            self.bodyHelper(containerSize: proxy.size, offsets: self.layout(self.data, proxy.size, self.sizes))
        }
    }
}

struct CollectionViewSizeKey<ID: Hashable>: PreferenceKey {
    typealias Value = [ID: CGSize]
    
    static var defaultValue: [ID: CGSize] { [:] }
    static func reduce(value: inout [ID:CGSize], nextValue: () -> [ID:CGSize]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct PropagateSize<V: View, ID: Hashable>: View {
    var content: V
    var id: ID
    var body: some View {
        content.background(GeometryReader { proxy in
            Color.clear.preference(key: CollectionViewSizeKey<ID>.self, value: [self.id: proxy.size])
        })
    }
}
