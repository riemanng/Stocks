//
//  Company.swift
//  Stocks
//
//  Created by DoroninKA on 04.09.2021.
//

import Foundation

struct Quote: Decodable {
    let companyName: String
    let symbol: String
    let latestPrice: Double
    let change: Double
}

struct Company: Decodable {
    let companyName: String
    let symbol: String
    let sector: String
    let description: String
}

struct Logo: Decodable {
    let url: String
}
