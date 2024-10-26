//
//  CustomNavLink.swift
//  LabLog
//
//  Created by Sophie Chew on 8/29/24.
//

import SwiftUI

struct CustomNavLinkLabel: View {
    let color: Color
    let size: sizes
    let label: () -> Text
    
    let hPadding: CGFloat
    let vPadding: CGFloat
    let fontSize: CGFloat
  
    @State var hover = false
    
    enum sizes {
        case small
        case normal
        case large
    }
    
    
    init(color: Color, size: sizes = .normal, @ViewBuilder label: @escaping () -> Text) {
        self.color = color
        self.label = label
        self.size = size
        switch size {
        case .small:
            self.hPadding = 5
            self.vPadding = 0
            self.fontSize = 20
        case .normal:
            self.hPadding = 20
            self.vPadding = 10
            self.fontSize = 30
        case .large:
            self.hPadding = 40
            self.vPadding = 30
            self.fontSize = 40
        }
    }
    
    var body: some View {
        
            label()
                .font(.custom("Poppins-Medium", size: fontSize))
                .padding(.horizontal, hPadding)
                .padding(.vertical, vPadding)
                .foregroundStyle(.foreground)
        
        .background(hover ? color.opacity(0.8) : color)
       .clipShape(Capsule())
       .onHover(perform: { hovering in
           hover = hovering
       })
    }
    
}

#Preview {
    CustomNavLinkLabel(color: .appBlue) {
        Text("Add +")
    }
}
