//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/09.
//

import Foundation
import SwiftUI

struct ProposalStatusView: View {
    var status: ProposalEntity.Status
    
    var body: some View {
        let label = status.label
        switch status {
        case .accepted:
            view(label: label, color: .green)
        case .activeReview:
            view(label: label, color: .orange)
        case .awaitingReview:
            view(label: label, color: .orange)
        case .deferred:
            view(label: label, color: .indigo)
        case .implemented(version: let version):
            Text("Swift \(version)")
                .font(.caption)
                .bold()
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.foreground, lineWidth: 1)
                )
                .opacity(0.8)
        case .previewing:
            view(label: label, color: .cyan)
        case .rejected:
            view(label: label, color: .red)
        case .returnedForRevision:
            view(label: label, color: .purple)
        case .withdrawn:
            view(label: label, color: .red)
        }
    }
    
    func view(label: String, color: Color) -> some View {
        Text(label)
            .font(.caption)
            .padding(4)
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 1)
            )
            .opacity(0.9)
    }
}
