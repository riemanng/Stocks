//
//  NetworkManager.swift
//  Stocks
//
//  Created by DoroninKA on 05.09.2021.
//

import Foundation

protocol NetworkManagerProtocol: AnyObject {
    func fetchQuote(for symbol: String, completion: @escaping (Result<Quote, Error>) -> Void)
    func fetchCompanies(list type: QuoteListType, completion: @escaping (Result<[Quote], Error>) -> Void)
    func fetchCompanyInfo(for symbol: String, completion: @escaping (Result<Company, Error>) -> Void)
}

final class NetworkManager: NetworkManagerProtocol {

    static let `default` = NetworkManager()

    func fetchQuote(for symbol: String, completion: @escaping (Result<Quote, Error>) -> Void) {
        guard let url = URL(string: EndPoint.quote(symbol).urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  (200...299).contains((response as? HTTPURLResponse)?.statusCode ?? -1),
                  let data = data
            else {
                print("🛑 Network Error")
                return
            }
            do {
                let quote = try JSONDecoder().decode(Quote.self, from: data)
                completion(.success(quote))
            } catch let error {
                completion(.failure(error))
                print("⚠️ Parsing error:")
                dump(error)
                print("===================")
            }
        }.resume()

    }

    func fetchCompanies(list type: QuoteListType, completion: @escaping (Result<[Quote], Error>) -> Void) {
        guard let url = URL(string: EndPoint.list(type).urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  (200...299).contains((response as? HTTPURLResponse)?.statusCode ?? -1),
                  let data = data
            else {
                print("🛑 Network Error")
                return
            }
            do {
                let companies = try JSONDecoder().decode([Quote].self, from: data)
                completion(.success(companies))
            } catch let error {
                completion(.failure(error))
                print("⚠️ Parsing error:")
                dump(error)
                print("===================")
            }
        }.resume()
    }

    func fetchCompanyInfo(for symbol: String, completion: @escaping (Result<Company, Error>) -> Void) {
        guard let url = URL(string: EndPoint.company(symbol).urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  (200...299).contains((response as? HTTPURLResponse)?.statusCode ?? -1),
                  let data = data
            else {
                print("🛑 Network Error")
                return
            }
            do {
                let company = try JSONDecoder().decode(Company.self, from: data)
                completion(.success(company))
            } catch let error {
                completion(.failure(error))
                print("⚠️ Parsing error:")
                dump(error)
                print("===================")
            }
        }.resume()
    }

    func fetchCompanyLogo(for symbol: String, completion: @escaping(Result<Logo, Error>) -> Void) {
        guard let url = URL(string: EndPoint.logo(symbol).urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  (200...299).contains((response as? HTTPURLResponse)?.statusCode ?? -1),
                  let data = data
            else {
                print("🛑 Network Error")
                return
            }
            do {
                let imageURL = try JSONDecoder().decode(Logo.self, from: data)

                completion(.success(imageURL))
            } catch let error {
                completion(.failure(error))
                print("⚠️ Parsing error:")
                dump(error)
                print("===================")
            }
        }.resume()
    }
    private init() {}
}
