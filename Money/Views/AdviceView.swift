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
                Group {
                    if type == .info {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                
                
                
                VStack(alignment: .leading) {
                    Text(advice.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(advice.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical)
        }
        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
        .padding(.horizontal)
        
    }
}

#Preview {
    AdviceView(type: .info, advice: .init(title: "Go Pro!", description: "Get insight on how to save money using premium advice"))
}
