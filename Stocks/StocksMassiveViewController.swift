//
//  StocksMassiveViewController.swift
//  Stocks
//
//  Created by DoroninKA on 04.09.2021.
//

import UIKit

final class StocksMassiveViewController: UIViewController {

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var companyPickerView: UIPickerView!

    private static let API_KEY = "pk_b5a7231057dc438597a25ec235633264"

    private let companies = ["Apple": "AAPL",
                             "Microsoft": "MSFT",
                             "Google": "GOOG",
                             "Amazon": "AMZN",
                             "Facebook": "FB",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()

        activityIndicator.hidesWhenStopped = true
        requestQuoteUpdate()
    }

    private func setDelegates() {
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
    }

    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double) {
        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
        symbolLabel.text = symbol
        priceLabel.text = "\(price)"
        priceChangeLabel.text = "\(priceChange)"
    }

    private func requestQuoteUpdate() {
        activityIndicator.startAnimating()
        companyNameLabel.text = "-"
        symbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"

        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(companies.values)[selectedRow]
        requestQuote(for: selectedSymbol)
    }

}

// MARK: - UIPickerViewDataSource
extension StocksMassiveViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        companies.count
    }
}

// MARK: - UIPickerViewDelegate
extension StocksMassiveViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Array(companies.keys)[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activityIndicator.startAnimating()

        let selectedSymbol = Array(companies.values)[row]
        requestQuote(for: selectedSymbol)
    }
}

// MARK: - Networking
private extension StocksMassiveViewController {
    func requestQuote(for symbol: String) {
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(StocksMassiveViewController.API_KEY)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let data = data
            else {
                assert(false, "🛑 Network Error")
                return
            }

            self.parseQuote(data: data)
        }.resume()
    }

    func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)

            guard let json = jsonObject as? [String: Any],
                  let companyName = json["companyName"] as? String,
                  let symbol = json["symbol"] as? String,
                  let price = json["latestPrice"] as? Double,
                  let priceChange = json["change"] as? Double
            else {
                assert(false, "🛑 Invalid JSON format")
                return
            }

            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName, symbol: symbol, price: price, priceChange: priceChange)
            }
        } catch {
            assert(false, "🛑 JSON parsing error: \(error.localizedDescription)")
        }
    }
}
