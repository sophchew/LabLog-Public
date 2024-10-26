//
//  CustomNavTitle.swift
//  LabLog
//
//  Created by Sophie Chew on 7/1/24.
//

import SwiftUI

struct CustomNavTitle: View {
    let text: String
    let size: sizes
    let fontSize: CGFloat
    
    init(text: String, size: sizes = .normal) {
        self.text = text
        self.size = size
        switch size {
            case .small:
            fontSize = 30
            case .normal:
            fontSize = 50
        }
    }
    enum sizes {
        case small
        case normal
    }
    
    var body: some View {
      
            HStack {
                Text(text)
                    .font(.custom("Poppins-Medium", size: fontSize))
                    .foregroundStyle(.foreground)
                    .padding(.leading, 30)
                Spacer()
            }
            
        
    }
}

#Preview {
    CustomNavTitle(text: "Nav")
}
