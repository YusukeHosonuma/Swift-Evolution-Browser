//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/20.
//

import Foundation

struct Suggestion: Equatable, Identifiable {
    var id: String { keyword } // `keyword` is uniqued.
    var keyword: String
    var completion: String
}
