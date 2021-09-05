//
//  StocksMassiveViewController.swift
//  Stocks
//
//  Created by DoroninKA on 04.09.2021.
//

import UIKit
import Kingfisher
import Network

final class StocksMassiveViewController: UIViewController {

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companyDescTextView: UITextView!

    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var arrowPriceChangeView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!

    private var companies: [Quote] = []

    let networkManager = NetworkManager.default

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        activityIndicator.hidesWhenStopped = true
        setInitialState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkConnection()
    }

    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        activityIndicator.startAnimating()
        var type: QuoteListType = .mostactive
        switch sender.selectedSegmentIndex {
        case 0:
            type = .mostactive
        case 1:
            type = .gainers
        case 2:
            type = .losers
        default:
            type = .mostactive
        }

        networkManager.fetchCompanies(list: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let list):
                DispatchQueue.main.async {
                    self.companies = list
                    self.companyPickerView.reloadAllComponents()
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print("Couldn't fetch companies, error: \(error)")
            }

        }
    }
}

// MARK: - Setup
extension StocksMassiveViewController {
    func setInitialState() {
        self.networkManager.fetchCompanies(list: .mostactive) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let list):
                DispatchQueue.main.async {
                    self.companies = list
                    self.companyPickerView.reloadAllComponents()
                }
            case .failure(let error):
                print("Couldn't fetch companies, error: \(error)")
            }
        }

        self.requestQuoteUpdate()
    }

    private func setDelegates() {
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
    }

    private func displayStockInfo(companyName: String,
                                  symbol: String,
                                  price: Double,
                                  priceChange: Double) {

        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
        symbolLabel.text = symbol
        priceLabel.text = "\(price)"
        priceChangeLabel.text = "\(priceChange)"
        setPriceChangeAndArrowColor(priceChange: priceChange)
    }

    private func displayAdditionalCompanyInfo(sector: String,
                                              description: String) {
        activityIndicator.stopAnimating()
        sectorLabel.text = sector
        companyDescTextView.text = description.count > 0 ? description : "No description."
    }

    private func setPriceChangeAndArrowColor(priceChange: Double) {
        if priceChange > 0 {
            priceChangeLabel.textColor = .green
            arrowPriceChangeView.image = UIImage(systemName: "arrow.up")
            arrowPriceChangeView.tintColor = .green
        } else if priceChange < 0 {
            priceChangeLabel.textColor = .red
            arrowPriceChangeView.image = UIImage(systemName: "arrow.down")
            arrowPriceChangeView.tintColor = .red
        } else {
            priceChangeLabel.textColor = .white
            arrowPriceChangeView.image = nil
        }
    }

    private func requestQuoteUpdate() {
        activityIndicator.startAnimating()
        companyNameLabel.text = "-"
        symbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"
        companyDescTextView.text = "-"
        sectorLabel.text = "-"
        priceChangeLabel.textColor = .white
        arrowPriceChangeView.image = nil
        logoImageView.image = nil

        sectorLabel.text = "-"
        companyDescTextView.text = "-"

        networkManager.fetchQuote(for: "AAPL") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let quote):
                DispatchQueue.main.async {
                    self.displayStockInfo(companyName: quote.companyName,
                                          symbol: quote.symbol,
                                          price: quote.latestPrice,
                                          priceChange: quote.change)

                    self.companyPickerView.reloadAllComponents()
                }
            case .failure(let error):
                print("⚠️ Couldn't get company info, error: \(error.localizedDescription)")
            }
        }

        networkManager.fetchCompanyInfo(for: "AAPL") { [weak self] result in
            switch result {
            case .success(let company):
                DispatchQueue.main.async {
                    self?.displayAdditionalCompanyInfo(sector: company.sector,
                                                       description: company.description)
                }
            case .failure(let error):
                print("⚠️ Couldn't get company info, error: \(error.localizedDescription)")
            }
        }

        networkManager.fetchCompanyLogo(for: "AAPL") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let logoURL):
                DispatchQueue.main.async {
                    self.logoImageView.layer.cornerRadius = 35
                    self.logoImageView.kf.setImage(with: URL(string: logoURL.url))
                }
            case .failure(let error):
                print("⚠️ Couldn't get company logo URL, error: \(error.localizedDescription)")
            }
        }
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
        companies[row].companyName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activityIndicator.startAnimating()

        let selectedSymbol = companies[row].symbol

        networkManager.fetchQuote(for: selectedSymbol) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let company):
                DispatchQueue.main.async {
                    self.displayStockInfo(companyName: company.companyName,
                                          symbol: company.symbol,
                                          price: company.latestPrice,
                                          priceChange: company.change)
                    self.companyPickerView.reloadAllComponents()
                }
            case .failure(let error):
                print("⚠️ Couldn't get quote info, error: \(error.localizedDescription)")
            }
        }

        networkManager.fetchCompanyInfo(for: selectedSymbol) { [weak self] result in
            switch result {
            case .success(let company):
                DispatchQueue.main.async {
                    self?.displayAdditionalCompanyInfo(sector: company.sector,
                                                       description: company.description)
                }
            case .failure(let error):
                print("⚠️ Couldn't get company info, error: \(error.localizedDescription)")
            }
        }

        networkManager.fetchCompanyLogo(for: selectedSymbol) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let logoURL):
                DispatchQueue.main.async {
                    self.logoImageView.layer.cornerRadius = 35
                    self.logoImageView.kf.setImage(with: URL(string: logoURL.url))
                }
            case .failure(let error):
                print("⚠️ Couldn't get company logo URL, error: \(error.localizedDescription)")
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = self.pickerView(pickerView, titleForRow: row, forComponent: component) ?? "No Content"
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

// MARK: - Check internet connection
extension StocksMassiveViewController {
    func checkConnection() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "stocks_connection_check")

        monitor.pathUpdateHandler = { pathHandler in
            if pathHandler.status == .satisfied {
                print("👍")
            } else {
                let alertVC = UIAlertController(title: "Attention",
                                              message: "You have lost connection with the network, please check your network settings and try again.",
                                              preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Exit", style: .default, handler: { _ in exit(0)}))
                DispatchQueue.main.async {
                    self.present(alertVC, animated: true)
                }
            }
        }

        monitor.start(queue: queue)
    }
}
