//
//  AdviceView.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-18.
//

import SwiftUI

enum AdviceType {
    case info, advice
}

struct AdviceView: View {

    var type: AdviceType
    var advice: Advice
    
    var body: some View {
        ZStack {
            if type == .info {
                Color.blue.opacity(0.2)
            } else {
                Color.green.opacity(0.2)
            }
            HStack {
                if type == .info {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                
                VStack(alignment: .leading) {
                    Text(advice.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(advice.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
        
    }
}

#Preview {
    AdviceView(type: .info, advice: .init(title: "Go Pro!", description: "Get insight on how to save money using premium advice"))
}
