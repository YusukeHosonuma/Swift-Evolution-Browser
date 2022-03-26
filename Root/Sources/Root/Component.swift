//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/25.
//

import Auth
import Core
import Foundation
import Proposal
import Service

final class Component {
    static let shared: Component = .init()

    //
    // 💾 Storage
    //
    let storageSelectedProposalIDAll = UserDefaultStorage<String?>(key: "selectedProposalIDAll", nil)
    let storageSelectedProposalIDStared = UserDefaultStorage<String?>(key: "selectedProposalIDStared", nil)

    //
    // ⚙️ Global Objects
    //
    lazy var authState: AuthState = .init()

    lazy var userService: UserService = UserServiceFirestore(authState: authState)

    lazy var proposalAPI: ProposalAPI = ProposalAPIClient()

    lazy var proposalDataSource: ProposalDataSource = ProposalDataSourceImpl(
        proposalAPI: proposalAPI,
        userService: userService
    )

    lazy var proposalListViewModelAll: ProposalListViewModel = .init(
        globalFilter: { _ in true },
        authState: authState,
        dataSource: proposalDataSource
    )

    lazy var proposalListViewModelStared: ProposalListViewModel = .init(
        globalFilter: { $0.star },
        authState: authState,
        dataSource: proposalDataSource
    )

    //
    // 🚀 Start-up all objects.
    //
    func ignite() async {
        await authState.onInitialize()
        await proposalDataSource.onInitialize()
    }
}
