//
//  CurrenciesLoader.swift
//  Currency converter
//
//  Created by Artem Pavlov on 21.02.17.
//  Copyright © 2017 Den prod. All rights reserved.
//

import Foundation

class CurrenciesLoader {
    
    func requestCurrentCurrencyRate(senderVC: ViewController) {
        senderVC.activityIndicator.startAnimating()
        senderVC.label.text = ""
        
        let baseCurrencyIndex = senderVC.pickerFrom.selectedRow(inComponent: 0)
        let toCurrencyIndex = senderVC.pickerTo.selectedRow(inComponent: 0)
        
        let baseCurrency = senderVC.currencies[baseCurrencyIndex]
        let toCurrency = senderVC.currenciesExeptBase()[toCurrencyIndex]
        
        
        self.retreiveCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency) { (value) in
            DispatchQueue.main.async(execute: {
                senderVC.label.text = value
                senderVC.activityIndicator.stopAnimating()
            })
            
        }
    }
    
    private func parseCurrencyRatesResponce(data: Data?, toCurrency: String) -> String {
        var value = ""
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
                if let rates = parsedJSON["rates"] as? Dictionary<String, Double> {
                    if let rate = rates[toCurrency] {
                        value = "\(rate)"
                    } else {
                        value = "No rate for currency \"\(toCurrency)\" found"
                    }
                } else {
                    value = "No \"rates\" field found"
                }
            } else {
                value = "No JSON value parsed"
            }
        } catch {
            value = error.localizedDescription
        }
        
        return value
    }
    
    private func getCurrencyRates(baseCurrency: String, pasreHandler: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: "https://api.fixer.io/latest?base=" + baseCurrency)!
        
        let dataTask = URLSession.shared.dataTask(with: url) { (dataReceived, response, error) in
            pasreHandler(dataReceived, error)
        }
        
        dataTask.resume()
    }
    
    private func retreiveCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (String) -> Void) {
        self.getCurrencyRates(baseCurrency: baseCurrency) { [weak self] (data, error) in
            var string = "No currency retrieved!"
            
            if let currentError = error {
                string = currentError.localizedDescription
            } else {
                if let strongSelf = self {
                    string = strongSelf.parseCurrencyRatesResponce(data: data, toCurrency: toCurrency)
                }
            }
            
            completion(string)
        }
    }
    
}
