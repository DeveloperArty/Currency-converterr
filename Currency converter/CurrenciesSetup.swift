//
//  CurrenciesSetup.swift
//  Currency converter
//
//  Created by Artem Pavlov on 20.02.17.
//  Copyright © 2017 Den prod. All rights reserved.
//

import Foundation

class CurrenciesSetup {
    
    private let latestURL = URL(string: "https://api.fixer.io/latest")!
    
    
    func getCurrenciesList(sender: GreetingViewController) {
        self.retrieveCurrencies(completion: { value in
            sender.currencies = value
        })

    }
    
    private func askForLatest(parseHandler: @escaping (Data?,Error?) -> Void ) {
        let dataTask = URLSession.shared.dataTask(with: self.latestURL) { (dataReceived, _, error) in
            parseHandler(dataReceived, error)
        }
        dataTask.resume()
    }
    
    private func retrieveCurrencies(completion: @escaping ([String]) -> Void ) {
        self.askForLatest() { [weak self] (data, error) in
            var supportedCurrencies: [String] = []
            if error == nil {
                if let strongSelf = self {
                    print("data received successfully; parse started")
                    supportedCurrencies = strongSelf.parseResponce(data: data)
                }
            } else {
                supportedCurrencies.append(error!.localizedDescription)
            }
            completion(supportedCurrencies)
            
        }
    }
    
    private func parseResponce(data: Data?) -> [String] {
        var allCurrencies = [String]()
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
                if let rates = parsedJSON["rates"] as? [String: Double] {
                    guard rates.isEmpty == false else {
                        let errorDesc = "No currencies found"
                        allCurrencies.append(errorDesc)
                        return allCurrencies
                    }
                    for (key, _) in rates {
                        allCurrencies.append(key)
                    }

                } else {
                    let errorDesc = "No \"rates\" field found"
                    allCurrencies.append(errorDesc)
                }
            } else {
                let errorDesc = "No JSON value parsed"
                allCurrencies.append(errorDesc)
            }
        } catch {
            let errorDesc = error.localizedDescription
            allCurrencies.append(errorDesc)
        }
        print(allCurrencies)
        return allCurrencies
    }
}
