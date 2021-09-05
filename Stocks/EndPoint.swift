//
//  EndPoint.swift
//  Stocks
//
//  Created by DoroninKA on 04.09.2021.
//

import Foundation

enum QuoteListType: String, CaseIterable {
    case mostactive
    case gainers
    case losers
}

enum EndPoint {

    static let baseUrl = "https://cloud.iexapis.com/stable/stock/"
    static let _API_KEY = "?token=pk_b5a7231057dc438597a25ec235633264"

    case quote(String)
    case logo(String)
    case company(String)
    case list(QuoteListType)

    var urlString: String {
        switch self {
        case .quote(let symbol):
            return EndPoint.baseUrl + symbol + "/quote" + EndPoint._API_KEY
        case .logo(let symbol):
            return EndPoint.baseUrl + symbol + "/logo" + EndPoint._API_KEY
        case .company(let symbol):
            return EndPoint.baseUrl + symbol + "/company" + EndPoint._API_KEY
        case .list(let type):
            return EndPoint.baseUrl + "market/list/" + type.rawValue + EndPoint._API_KEY
        }
    }
}
