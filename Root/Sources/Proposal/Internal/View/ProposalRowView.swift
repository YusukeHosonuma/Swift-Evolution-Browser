//
//  File.swift
//
//
//  Created by 細沼祐介 on 2022/03/04.
//

import SwiftUI

struct ProposalRowView: View {
    let proposal: Proposal
    let onTapStar: () -> Void

    init(
        proposal: Proposal,
        starTapped: @escaping () -> Void
    ) {
        self.proposal = proposal
        onTapStar = starTapped
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(proposal.id)
                    .font(.headline)
                    .bold()
                Spacer()
                ProposalStatusView(status: proposal.status)
            }
            Spacer()
            HStack(alignment: .bottom) {
                Text(proposal.title)
                    .font(.subheadline)
                Spacer()
                Image(systemName: proposal.star ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        onTapStar()
                    }
            }
        }
    }
}

struct ProposalRowView_Previews: PreviewProvider {
    static let proposals: [Proposal] = [
        Proposal(
            id: "SE-0335",
            title: "Introduce existential any",
            star: false,
            proposalURL: URL(string: "https://github.com/")!,
            status: .implemented(version: "5.4")
        ),
        Proposal(
            id: "SE-0334",
            title: "Pointer API Usability Improvements",
            star: false,
            proposalURL: URL(string: "https://github.com/")!,
            status: .awaitingReview
        ),
        Proposal(
            id: "SE-0345",
            title: "if let shorthand for shadowing an existing optional variable",
            star: false,
            proposalURL: URL(string: "https://github.com/")!,
            status: .awaitingReview
        ),
        Proposal(
            id: "SE-0090",
            title: "Remove .self and freely allow type references in expressions",
            star: false,
            proposalURL: URL(string: "https://github.com/")!,
            status: .deferred
        ),

        Proposal(
            id: "SE-0288",
            title: "Adding isPower(of:) to BinaryInteger",
            star: false,
            proposalURL: URL(string: "https://github.com/")!,
            status: .previewing
        ),
        Proposal(
            id: "SE-0275",
            title: "Allow more characters (like whitespaces and punctuations) for escaped identifiers",
            star: false,
            proposalURL: URL(string: "https://github.com/")!,
            status: .rejected
        ),
        Proposal(
            id: "SE-0330",
            title: "Conditionals in Collections",
            star: false,
            proposalURL: URL(string: "https://github.com/")!,
            status: .returnedForRevision
        ),
        Proposal(
            id: "SE-0223",
            title: "Accessing an Array's Uninitialized Buffer",
            star: false,
            proposalURL: URL(string: "https://github.com/")!,
            status: .withdrawn
        ),
    ]

    static var previews: some View {
        List(proposals, id: \.id) { proposal in
            ProposalRowView(proposal: proposal, starTapped: {})
        }
        .environment(\.colorScheme, .dark)

        List(proposals, id: \.id) { proposal in
            ProposalRowView(proposal: proposal, starTapped: {})
        }
        .environment(\.colorScheme, .light)
    }
}
