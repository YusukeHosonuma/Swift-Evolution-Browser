//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/09.
//

import Core
import Foundation
import SwiftUI

struct ProposalStatusView: View {
    var status: Proposal.Status

    var body: some View {
        let v = statusLabelView

        switch status {
        case .accepted:
            v(.green)
        case .activeReview:
            v(.orange)
        case .awaitingReview:
            v(.orange)
        case .deferred:
            v(.indigo)
        case let .implemented(version: version):
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
            v(.cyan)
        case .rejected:
            v(.red)
        case .returnedForRevision:
            v(.purple)
        case .withdrawn:
            v(.red)
        case .scheduledForReview:
            v(.orange)
        case .unknown:
            EmptyView()
        }
    }

    func statusLabelView(color: Color) -> some View {
        Text(status.label)
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
