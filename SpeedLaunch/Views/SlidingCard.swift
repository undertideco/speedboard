//
//  SlidingCard.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/14/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

enum CardPosition {
    case dismissed, expanded
    
    func offsetFromTop() -> CGFloat {
        switch self {
        case .dismissed:
            return UIScreen.main.bounds.height - 200
        case .expanded:
            return UIScreen.main.bounds.height / 1.8
        }
    }
}
enum DragState {
    
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

struct SlidingCard<Content>: View where Content : View {
    @Binding var defaultPosition: CardPosition
    var content: () -> Content
    
    var body: some View {
        ModifiedContent(content: content(), modifier: Card(position: self.$defaultPosition))
    }
}

struct Card: ViewModifier {
    @GestureState var dragState: DragState = .inactive
    @Binding var position : CardPosition
    @State var offset: CGSize = CGSize.zero
    
    var animation: Animation {
        Animation.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
    }
    
    var timer: Timer? {
        return Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            if self.position == .expanded && self.dragState.translation.height == 0  {
                self.position = .expanded
            } else {
                timer.invalidate()
            }
        }
    }
    
    func body(content: Content) -> some View {
        let drag = DragGesture()
                    .updating($dragState) { drag, state, transaction in state = .dragging(translation:  drag.translation) }
                    .onChanged {_ in
                        self.offset = .zero
                }
                .onEnded(onDragEnded)
        
        return ZStack(alignment: .top) {
            ZStack(alignment: .top) {
                Color(UIColor.systemGray6)
                Handle()
                content.padding(.top, 20)
            }
            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(x: 1, y: 1, anchor: .center)
        }
        .offset(y: max(0, self.position.offsetFromTop() + self.dragState.translation.height))
        .animation(self.dragState.isDragging ? nil : animation)
        .gesture(drag)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        // Setting stops
        let higherStop: CardPosition
        let lowerStop: CardPosition

        // Nearest position for drawer to snap to.
        let nearestPosition: CardPosition

        // Determining the direction of the drag gesture and its distance from the top
        let dragDirection = drag.predictedEndLocation.y - drag.location.y
        let offsetFromTopOfView = position.offsetFromTop() + drag.translation.height

        // Determining whether drawer is above or below `.partiallyRevealed` threshold for snapping behavior.
        if offsetFromTopOfView <= CardPosition.dismissed.offsetFromTop() {
            higherStop = .expanded
            lowerStop = .dismissed
        } else {
           higherStop = .expanded
           lowerStop = .dismissed
        }

        // Determining whether drawer is closest to top or bottom
        if (offsetFromTopOfView - higherStop.offsetFromTop()) < (lowerStop.offsetFromTop() - offsetFromTopOfView) {
           nearestPosition = higherStop
        } else {
           nearestPosition = lowerStop
        }

        // Determining the drawer's position.
        if dragDirection > 0 {
           position = lowerStop
        } else if dragDirection < 0 {
           position = higherStop
        } else {
           position = nearestPosition
        }
        _ = timer
       }
}

struct Handle : View {
    private let handleThickness = CGFloat(5.0)
    var body: some View {
        RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(Color.secondary)
            .padding(5)
    }
}
